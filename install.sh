#!/bin/bash

# Get the directory this script is in
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup for neovim
mkdir -p ~/.config
ln -s $ROOT/nvim ~/.config/nvim

# git
ln -sf $ROOT/git/.gitconfig ~

# Python
ln -sf $ROOT/python/.flake8 ~
ln -sf $ROOT/python/.pep8 ~
ln -sf $ROOT/python/pycodestyle ~/.config/pycodestyle

# R
ln -sf $ROOT/r/.lintr ~

# Setup for Other Unix Tools
ln -sf $ROOT/bash/.bash_aliases ~
ln -sf $ROOT/bash/.bash_functions ~
ln -sf $ROOT/bash/.tmux.conf ~
ln -sf $ROOT/bash/.inputrc ~

if ! grep -q ".bash_aliases" ~/.bashrc; then
  echo $'\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n' >>~/.bashrc
fi

if ! grep -q ".bash_functions" ~/.bashrc; then
  echo $'\nif [ -f ~/.bash_functions ]; then\n    . ~/.bash_functions\nfi\n' >>~/.bashrc
fi

# Agent skills

mkdir -p ~/.agents
SKILLS_DIR="$HOME/.agents/skills"

if [ -d "$SKILLS_DIR" ] && [ ! -L "$SKILLS_DIR" ]; then
  if [ -n "$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    echo "Error: $SKILLS_DIR already exists and is non-empty" >&2
    exit 1
  fi

  rmdir "$SKILLS_DIR"
fi

ln -sfn "$ROOT/agent_skills" "$SKILLS_DIR"
