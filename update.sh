#!/bin/bash

git commit -a
git push
command cp bashrc-append.sh ~/.bashrc-append.sh
. ~/.bashrc-append.sh
command cp gitconfig ~/.gitconfig
command cp vimrc ~/.vimrc
