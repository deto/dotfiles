#!/bin/bash
for i in $(find `pwd` -name '*.linux-symlink' );
do
    filename=$(basename "$i")
    rootname="${filename%.*}"
    newfile="~/$rootname"
    echo "Linking $i to $newfile"
    eval ln -s $i $newfile
done

for i in $(find `pwd` -name '*.symlink' );
do
    filename=$(basename "$i")
    rootname="${filename%.*}"
    newfile="~/$rootname"
    echo "Linking $i to $newfile"
    eval ln -s $i $newfile
done

# Setup for neovim
if [ ! -d ~/.config ]; then
    mkdir ~/.config
fi

if [ ! -d ~/.config/nvim ]; then
    mkdir ~/.config/nvim
fi

if [ ! -d ~/.config/nvim/autoload/plug.vim ]; then
    curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

ln -s $(pwd)/vim/init.vim ~/.config/nvim/init.vim
ln -s $(pwd)/vim/ginit.vim ~/.config/nvim/ginit.vim
