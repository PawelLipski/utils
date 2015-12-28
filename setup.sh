#!/bin/bash

git clone https://github.com/tilius/utils.git
cd utils
cp bashrc-append.sh ~/.bashrc-append.sh
echo '. ~/.bashrc-append.sh' >> ~/.bashrc
. ~/.bashrc-append.sh
cp gitconfig ~/.gitconfig
cp vimrc ~/.vimrc
cd ..
rm -rf utils

