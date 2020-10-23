#!/bin/bash

\cp bashrc-append.sh ~/.bashrc-append.sh
. ~/.bashrc-append.sh
\cp gitconfig ~/.gitconfig
\cp inputrc ~/.inputrc
\cp vimrc ~/.vimrc
mkdir -p ~/.local/bin
\cp kubectl-* ~/.local/bin
