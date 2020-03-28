#!/bin/sh -eux

echo "app.sh party"

apt-get install fish docker-ce docker-ce-cli containerd.io libncurses5-dev pkg-config -y

mkdir -p $HOME/.config/fish/

cat <<EOF >> $HOME/.config/fish/config.fish
abbr -a -U -- .list 'apt list --upgradable'
abbr -a -U -- .pull 'docker-compose pull'
abbr -a -U -- .stop 'docker stop (docker ps -a -q)'
abbr -a -U -- .up 'docker-compose up -d'
abbr -a -U -- .update 'sudo apt update'
abbr -a -U -- .upgrade 'sudo apt upgrade -y'
abbr -a -U -- dprune 'docker image prune -a'
abbr -a -U -- dps 'docker ps -a'
abbr -a -U -- drm 'docker rm'
abbr -a -U -- gp 'git pull'
abbr -a -U -- gP 'git push'
abbr -a -U -- gPt 'git push --tags'
abbr -a -U -- gc 'git clone'
abbr -a -U -- gcom 'git commit -m'
abbr -a -U -- gp 'git pull'
abbr -a -U -- l 'ls -lah'
EOF

curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

apt-get update

echo "progress"

cd $HOME
mkdir initial-setup
cd initial-setup

git clone https://github.com/Xfennec/progress.git

cd progress
make && make install

cd ../
rm -rf progress

echo "starship"

apt-get install fonts-firacode -y

wget -q --show-progress https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz

tar xvf starship-x86_64-unknown-linux-gnu.tar.gz

mv starship /usr/local/bin/

echo "starship init fish | source" | tee -a $HOME/.config/fish/config.fish

echo "Cleaning up from initial setup"

cd ../
rm -r initial-setup

systemctl enable docker

echo "adding docker group"

usermod -aG docker $USER

echo "enabling fish shell"

sed s/required/sufficient/g -i /etc/pam.d/chsh
echo "/usr/bin/fish" | tee -a /etc/shells

chsh $USER -s /usr/bin/fish