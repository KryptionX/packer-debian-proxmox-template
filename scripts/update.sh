#!/bin/sh -eux

echo 'Acquire::http { Proxy "http://10.10.25.120:3142"; };' | tee -a /etc/apt/apt.conf.d/apt_cacher_proxy

arch="`uname -r | sed 's/^.*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\(-[0-9]\{1,2\}\)-//'`"
debian_version="`lsb_release -r | awk '{print $2}'`";
major_version="`echo $debian_version | awk -F. '{print $1}'`";

# # Disable systemd apt timers/services
if [ "$major_version" -ge "9" ]; then
  systemctl stop apt-daily.timer;
  systemctl stop apt-daily-upgrade.timer;
  systemctl disable apt-daily.timer;
  systemctl disable apt-daily-upgrade.timer;
  systemctl mask apt-daily.service;
  systemctl mask apt-daily-upgrade.service;
  systemctl daemon-reload;
fi

# Disable periodic activities of apt
cat <<EOF >/etc/apt/apt.conf.d/10periodic;
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

apt-get update;

apt-get -y upgrade linux-image-$arch;
apt-get -y install linux-headers-`uname -r`;
