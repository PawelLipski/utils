#!/usr/bin/env bash

set -e -u

echo -e "\nsource $PWD/bashrc-append.sh" >> ~/.bashrc
git config --global include.path $PWD/gitconfig
ln -s $PWD/inputrc ~/.inputrc
ln -s $PWD/vimrc ~/.vimrc
