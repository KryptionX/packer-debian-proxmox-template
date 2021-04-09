variable "proxmox_host" {}
variable "proxmox_node_name" {}
variable "proxmox_api_user" {}
variable "proxmox_api_password" {}
variable "template_name" {}
variable "template_description" {}
variable "ssh_fullname" {}
variable "ssh_password" {}
variable "ssh_username" {}
variable "hostname" {}
variable "domain" {}
variable "vmid" {}
variable "locale" {}
variable "cores" {}
variable "sockets" {}
variable "memory" {}
variable "disk_size" {}
variable "datastore" {}
variable "datastore_type" {}
variable "iso" {}
variable "preseed_file" {}
variable "ipconfig" {}
variable "ciuser" {}

source "proxmox" "base" {
  boot_command = [
    "<esc><wait>",
    "install ",
    "initrd=/install/initrd.gz ",
    "auto-install/enable=true ",
    "debconf/priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ",
    "locale=en_US.UTF-8 ",
    "kbd-chooser/method=us ",
    "netcfg/get_hostname=${var.hostname} ",
    "netcfg/get_domain=${var.domain} ",
    "passwd/username=${var.ssh_username} ",
    "passwd/user-fullname=${var.ssh_fullname} ",
    "passwd/user-password=${var.ssh_password} ",
    "passwd/user-password-again=${var.ssh_password} ",
    "keyboard-configuration/xkb-keymap=us<wait> ",
    "console-setup/ask_detect=false<wait> ",
    "debconf/frontend=noninteractive<wait> ",
    "console-keymaps-at/keymap=us ",
    "fb=false ",
    "grub-installer/bootdev=/dev/sda ",
    "<enter><wait>"
    ,]
  # boot_key_interval = "65ms"
  boot_wait         = "5s"
  cores             = "${var.cores}"
  disks {
    cache_mode        = "none"
    disk_size         = "${var.disk_size}"
    format            = "raw"
    storage_pool      = "${var.datastore}"
    storage_pool_type = "${var.datastore_type}"
    type              = "scsi"
  }
  http_directory           = "./http"
  insecure_skip_tls_verify = true
  iso_file                 = "${var.iso}"
  memory                   = "${var.memory}"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  node                 = "${var.proxmox_node_name}"
  os                   = "l26"
  password             = "${var.proxmox_api_password}"
  proxmox_url          = "https://${var.proxmox_host}:8006/api2/json"
  qemu_agent           = true
  sockets              = "${var.sockets}"
  ssh_password         = "${var.ssh_password}"
  ssh_timeout          = "90m"
  ssh_username         = "${var.ssh_username}"
  template_description = "${var.template_description}"
  unmount_iso          = true
  username             = "${var.proxmox_api_user}"
  vm_id                = "${var.vmid}"
  vm_name              = "${var.template_name}"
}

build {
  sources = ["source.proxmox.base"]

  provisioner "shell" {
    environment_vars  = ["DEBIAN_FRONTEND=noninteractive", "HOME_DIR=/home/johnny"]
    execute_command   = "echo 'packer' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["./scripts/update.sh", "./scripts/networking.sh", "./scripts/systemd.sh", "./scripts/keys.sh", "./scripts/repos.sh", "./scripts/ssh.sh", "./scripts/cleanup.sh"]
  }

  provisioner "file" {
    destination = "/tmp/usersetup.sh"
    source      = "./scripts/user/usersetup.sh"
  }

  provisioner "file" {
    destination = "/tmp/github"
    source      = "./scripts/user/github"
  }

  provisioner "file" {
    destination = "/tmp/motd.txt"
    source      = "./scripts/user/motd.txt"
  }

  provisioner "file" {
    destination = "/tmp/motd_function.txt"
    source      = "./scripts/user/motd_function.txt"
  }

  provisioner "file" {
    destination = "/tmp/start.sh"
    source      = "./scripts/user/start.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    script          = "./scripts/move-files.sh"
  }

  post-processor "shell-local" {
    inline = ["sudo su -", "qm set ${var.vmid} --scsihw virtio-scsi-pci", "qm set ${var.vmid} --ide2 ${var.datastore}:cloudinit", "qm set ${var.vmid} --boot c --bootdisk scsi0", "qm set ${var.vmid} --ciuser ${var.ciuser}", "qm set ${var.vmid} --vga std", "qm set ${var.vmid} --ipconfig0 ${var.ipconfig}"]
  }
}
