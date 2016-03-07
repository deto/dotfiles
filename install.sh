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

# Some more setup for vim
if [ ! -d ~/.vim ]; then
    mkdir ~/.vim
fi

if [ ! -d ~/.vim/swap ]; then
    mkdir ~/.vim/swap
fi

if [ ! -d ~/.vim/bundle ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
