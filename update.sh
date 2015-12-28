#!/bin/bash

git commit -a
git push
cp bashrc-append.sh ~/.bashrc-append.sh
. ~/.bashrc-append.sh
cp gitconfig ~/.gitconfig
cp vimrc ~/.vimrc
