#!/bin/bash

command cp bashrc-append.sh ~/.bashrc-append.sh
. ~/.bashrc-append.sh
command cp gitconfig ~/.gitconfig
command cp inputrc ~/.inputrc
command cp vimrc ~/.vimrc
mkdir ~/.local/bin
command cp kubectl-* ~/.local/bin
