#!/usr/bin/env bash

# spicetify.sh - wallbash hook to apply generated colors to spicetify
#
# Triggered by spicetify.dcol on every wallbash/theme switch.
# The .dcol template writes substituted colors to:
#   $cacheDir/wallbash/spicetify.ini  ([Wallbash] section)
# This script copies that over color.ini and re-applies spicetify.

# shellcheck source=$HOME/.local/bin/hyde-shell
# shellcheck disable=SC1091

_hyde_shell=$(command -v hyde-shell 2>/dev/null) || true
if [[ -z "$_hyde_shell" ]] || ! source "$_hyde_shell"; then
    echo "[wallbash] spicetify :: Error: hyde-shell not found."
    exit 1
fi
unset _hyde_shell

confDir="${confDir:-$HOME/.config}"
cacheDir="${cacheDir:-$XDG_CACHE_HOME/hyde}"

spicetify_theme_dir="${confDir}/spicetify/Themes/Dracula"
color_ini="${spicetify_theme_dir}/color.ini"
generated_ini="${cacheDir}/wallbash/spicetify.ini"

# Only run if both spicetify-cli and spotify are installed
if ! pkg_installed spicetify-cli; then
	echo "[wallbash] spicetify :: spicetify-cli not installed, skipping."
	exit 0
fi

if ! pkg_installed spotify; then
	echo "[wallbash] spicetify :: spotify not installed, skipping."
	exit 0
fi

# Ensure spotify dirs are writable (first-run only)
if [ ! -w /opt/spotify ] || [ ! -w /opt/spotify/Apps ]; then
	notify-send -a "HyDE" "Spicetify needs permission to theme Spotify" -i dialog-information
	pkexec chmod a+wr /opt/spotify
	pkexec chmod a+wr /opt/spotify/Apps -R
fi

# Copy the wallbash-generated colors over color.ini
if [ -f "${generated_ini}" ]; then
	cp "${generated_ini}" "${color_ini}"
	echo "[wallbash] spicetify :: colors applied to ${color_ini}"
else
	echo "[wallbash] spicetify :: generated ini not found: ${generated_ini}"
	exit 1
fi

# Bootstrap spicetify config if color_scheme is not Wallbash yet
current_scheme=$(spicetify config 2>/dev/null | awk '/color_scheme/ {print $2}')
if [ "${current_scheme}" != "Wallbash" ]; then
	echo "[wallbash] spicetify :: bootstrapping theme to Dracula/Wallbash"
	mkdir -p "${HOME}/.config/spotify"
	touch "${HOME}/.config/spotify/prefs"
	sptfyConf=$(spicetify -c)
	sed -i "/^prefs_path/ s+=.*$+= ${HOME}/.config/spotify/prefs+g" "${sptfyConf}"
	spicetify backup apply
	spicetify config current_theme Dracula
	spicetify config color_scheme Wallbash
	spicetify apply
fi

# Hot-reload if spotify is running
if pgrep -x spotify >/dev/null; then
	pkill -x spicetify 2>/dev/null
	spicetify -q watch -s &
	disown
	echo "[wallbash] spicetify :: hot-reload triggered"
fi
