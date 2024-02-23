#!/usr/bin/env bash

set -e -u

u=$HOME/utils
git clone https://github.com/PawelLipski/utils.git $u
echo -e "\nsource $u/bashrc-append.sh" >> ~/.bashrc
ln -s $u/gitconfig ~/.inputrc
ln -s $u/inputrc ~/.inputrc
ln -s $u/vimrc ~/.vimrc
