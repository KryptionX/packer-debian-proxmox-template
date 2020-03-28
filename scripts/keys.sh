#!/bin/sh -eux

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

cd $HOME
mkdir initial-setup
cd initial-setup

wget -nv https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key -O Release.key

apt-key add - < Release.key

rm Release.key
