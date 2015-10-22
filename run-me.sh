git clone https://github.com/tilius/utils.git
cd utils
cp bashrc-append.sh ~/.bashrc-append.sh
echo '. ~/.bashrc-append.sh' >> ~/.bashrc
cp gitconfig ~/.gitconfig
cp vimrc ~/.vimrc
cd ..
rm -rf utils

