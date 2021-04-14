#!/usr/bin/env bash

grep -qxF '. ~/.bashrc-append.sh' ~/.bashrc || echo '. ~/.bashrc-append.sh' >> ~/.bashrc
\cp bashrc-append.sh ~/.bashrc-append.sh
. ~/.bashrc-append.sh
\cp gitconfig ~/.gitconfig
\cp inputrc ~/.inputrc
\cp vimrc ~/.vimrc
mkdir -p ~/.local/bin
\rm -f ~/.local/bin/kubectl-*
\cp kubectl-* ~/.local/bin
