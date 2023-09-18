#!/bin/bash

ROOT=$(pwd)

# Setup for neovim
mkdir -p ~/.config
mkdir -p ~/.config/nvim

if [ ! -f ~/.config/nvim/autoload/plug.vim ]; then
    curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

ln -sf $ROOT/vim/init.vim ~/.config/nvim
ln -sf $ROOT/vim/init_minimal.vim ~/.config/nvim
ln -sf $ROOT/vim/coc-settings.json ~/.config/nvim

nvim --headless +PlugInstall +qa

# git
ln -sf $ROOT/git/.gitconfig ~

# Python
ln -sf $ROOT/python/.flake8 ~
ln -sf $ROOT/python/.pep8 ~
ln -sf $ROOT/python/pycodestyle ~/.config/pycodestyle

# $
ln -sf $ROOT/r/.lintr ~

mkdir -p ~/.jupyter/custom
ln -sf $ROOT/python/jupyter_custom.js ~/.jupyter/custom/custom.js

mkdir -p ~/.config/matplotlib
ln -sf $ROOT/python/matplotlibrc ~/.config/matplotlib

# Setup for Other Unix Tools
ln -sf $ROOT/bash/.bash_aliases ~
ln -sf $ROOT/bash/.bash_functions ~
ln -sf $ROOT/bash/.tmux.conf ~
ln -sf $ROOT/bash/.inputrc ~

if ! grep -q ".bash_aliases" ~/.bashrc ; then
    echo $'\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n' >> ~/.bashrc
fi

if ! grep -q ".bash_functions" ~/.bashrc ; then
    echo $'\nif [ -f ~/.bash_functions ]; then\n    . ~/.bash_functions\nfi\n' >> ~/.bashrc
fi
