#!/bin/bash

# setup configs in HOME and .config

to_home=(
  ".gitconfig"
  "tmux/.tmux.conf"
  "zsh/.zshrc"
)

for i in "${to_home[@]}"
do
  $(ln -sf $PWD/$i $HOME)
done

echo "created dotfiles symlinks in HOME"

config_dir=$HOME/.config

if [ ! -d $config_dir ]; then
  $(mkdir $config_dir)

  echo "created .config dir in HOME"
fi

if [ ! -d $config_dir/lazygit ]; then
  $(mkdir $config_dir/lazygit)

  echo "created lazygit dir in .config"
fi

if [ -f $config_dir/lazygit/config.yml ]; then
  rm -rf $config_dir/lazygit/config.yml
fi

$(ln -sf $PWD/lazygit/config.yml $config_dir/lazygit)

echo "created lazygit config symlink in .config/lazygit"

if [ -d $config_dir/nvim ]; then
  rm -rf $config_dir/nvim
fi

$(ln -sf $PWD/nvim_agr $config_dir/nvim)

echo "created nvim config symlink in .config/nvim"

if [ -f $config_dir/starship.toml ]; then
  rm -rf $config_dir/starship.toml
fi

$(ln -sf $PWD/starship/starship.toml $config_dir)

echo "created starship config symlink in .config"

# move helper scripts into local bin

local_bin=$HOME/.local/bin

if [ ! -d $local_bin ]; then
  $(mkdir $local_bin)
  echo "created local bin dir"
fi

to_bin=(
  "starship/git_check_if_inside"
  "starship/git_get_host"
  "starship/git_time_since_change"
)

for i in "${to_bin[@]}"
do
  $(chmod +x $PWD/$i)
  $(ln -sf $PWD/$i $local_bin)
done

echo "created local bin symlinks"

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
