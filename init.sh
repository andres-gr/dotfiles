#!/bin/bash

# Stow
if command -v stow &> /dev/null; then
  stow -v home -t $HOME
  echo "stowed dotfiles"
else
  echo "stow not installed"
fi

# copy .gitconfig to home
if [ -f $HOME/.gitconfig ]; then
  mv $HOME/.gitconfig $HOME/.gitconfig.bak
fi

cp -rf $PWD/.gitconfig $HOME

if command -v tmux &> /dev/null; then
  if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    $(git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm")
  fi
fi

# make executable scripts
to_make_exec=(
  "rmParser.sh"
  "rmUpdate.sh"
)

for i in "${to_make_exec[@]}"
do
  $(chmod +x $PWD/$i)
done

echo "made scripts executable"

# setup plugins for .zshrc to use

plugins_dir=$HOME/devel/plugins

if [ ! -d $plugins_dir ]; then
  $(mkdir $plugins_dir)

  echo "created plugins dir"
fi

plugins_dir_names=(
  "evalcache"
  "fast-syntax-highlighting"
  "git"
  "ohmyzsh"
  "omz-plugin-pnpm"
  "z.lua"
  "zsh-autosuggestions"
  "zsh-completions"
  "zsh-history-substring-search"
)

plugins_repos=(
  "https://github.com/mroth"
  "https://github.com/zdharma-continuum"
  "https://github.com/davidde"
  "https://github.com/ohmyzsh"
  "https://github.com/ntnyq"
  "https://github.com/skywind3000"
  "https://github.com/zsh-users"
  "https://github.com/zsh-users"
  "https://github.com/zsh-users"
)

for i in "${!plugins_dir_names[@]}"
do
  if [ ! -d "$plugins_dir/${plugins_dir_names[$i]}" ]; then
    $(git -C $plugins_dir clone "${plugins_repos[$i]}/${plugins_dir_names[$i]}")

    echo " "
    echo "cloned ${plugins_dir_names[$i]}"
    echo " "
    echo " "
  fi
done

echo " "
echo "init done"
echo " "
