#!/bin/sh -eux

sudo chmod 755 *.sh
sudo chown johnny:johnny *.sh
sudo chmod 600 github
sudo chown johnny:johnny github
sudo chmod 755 *.txt
sudo chown johnny:johnny *.txt

mkdir -p $HOME/setup
sudo chown johnny:johnny $HOME/setup

sudo mv /home/usersetup.sh $HOME/setup/
sudo mv /home/github $HOME/.ssh/github
sudo mv /home/*.txt $HOME/setup/
