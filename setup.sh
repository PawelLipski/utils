#!/usr/bin/env bash

set -e -u

echo -e "\nsource $PWD/bashrc-append.sh" >> ~/.bashrc
ln -s $PWD/gitconfig ~/.gitconfig
ln -s $PWD/inputrc ~/.inputrc
ln -s $PWD/vimrc ~/.vimrc
