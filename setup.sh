#!/bin/bash

git clone https://github.com/tilius/utils.git
cd utils
command cp bashrc-append.sh ~/.bashrc-append.sh
echo '. ~/.bashrc-append.sh' >> ~/.bashrc
. ~/.bashrc-append.sh
command cp gitconfig ~/.gitconfig
command cp vimrc ~/.vimrc
cd ..
rm -rf utils

