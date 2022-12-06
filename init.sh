#!/bin/bash

to_home=(
  ".gitconfig"
  ".tmux.conf"
  ".zshrc"
)

for i in "${to_home[@]}"
do
  $(eval "ln -sf $PWD/$i $HOME")
done

if [ ! -d $HOME/.config ]; then
  $(eval "mkdir $HOME/.config")
fi

if [ ! -d $HOME/.config/lazygit ]; then
  $(eval "mkdir $HOME/.config/lazygit")
fi

$(eval "ln -sf $PWD/lazygit/config.yml $HOME/.config/lazygit")

$(eval "ln -sf $PWD/nvim_agr $HOME/.config/nvim")

$(eval "ln -sf $PWD/starship.toml $HOME/.config")

