#!/bin/bash

to_home=(
  ".zshrc"
  ".gitconfig"
  ".tmux.conf"
)

for i in "${to_home[@]}"
do
  $(eval "ln -sf $PWD/$i $HOME")
done

