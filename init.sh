#!/bin/bash

# setup configs in HOME and .config

to_home=(
  "tmux/.tmux.conf"
  "zsh/.zshrc"
)

for i in "${to_home[@]}"
do
  $(ln -sf $PWD/$i $HOME)
done

echo "created dotfiles symlinks in HOME"

# copy .gitconfig to home
if [ -f $HOME/.gitconfig ]; then
  mv $HOME/.gitconfig $HOME/.gitconfig.bak
fi

cp -rf $PWD/.gitconfig $HOME

config_dir=$HOME/.config

if [ ! -d $config_dir ]; then
  $(mkdir $config_dir)

  echo "created .config dir in HOME"
fi

if command -v tmux &> /dev/null; then
  if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    $(git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm")
  fi
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

if [ -d $config_dir/wezterm ]; then
  rm -rf $config_dir/wezterm
fi

$(ln -sf $PWD/wezterm $config_dir/wezterm)

echo "created wezterm config symlink in .config/wezterm"

# if [ -d $config_dir/yabai ]; then
  # rm -rf $config_dir/yabai
# fi

# $(ln -sf $PWD/yabai $config_dir/yabai)

# echo "created yabai config symlink in .config/yabai"

# if [ -d $config_dir/skhd ]; then
  # rm -rf $config_dir/skhd
# fi

# $(ln -sf $PWD/skhd $config_dir/skhd)

# echo "created skhd config symlink in .config/skhd"

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
