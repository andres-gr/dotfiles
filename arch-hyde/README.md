# arch-hyde

This stow package contains HyDE (Hyprland Development Environment) and Hyprland-specific configurations.

## Contents

### `.config/`
| Directory/File | Description |
|----------------|-------------|
| `hyde/` | HyDE main configuration and themes |
| `hypr/` | Hyprland compositor configuration |
| `waybar/` | Wayland status bar configuration |
| `swaync/` | Sway notification center |
| `wallbash/` | Wallpaper and color theming |
| `spicetify/` | Spotify client theming |
| `wlogout/` | Wayland logout/restart menu |
| `rofi/styles/` | Rofi application launcher styles |

### `.local/`
| Directory/File | Description |
|----------------|-------------|
| `bin/media-watch.sh` | Media playback watcher for waybar |
| `bin/spotify-scrolling` | Spotify scrolling module for waybar |
| `share/wallbash/` | Wallpaper theming scripts |

## Usage

This package is automatically selected when HyDE is detected on your system.

## Requirements

- Hyprland compositor
- HyDE (Hyprland Development Environment)
- Waybar
- Rofi
- SwayNC (notification daemon)

## Included Themes

- **Dracula Pro** - Dark theme across all components
  - Hyprland colors
  - Waybar styling
  - Rofi styling
  - Spicetify styling
  - Ghostty terminal

## Key Configuration Files

- `hypr/keybindings.conf` - Window manager keybindings
- `hypr/userprefs.conf` - Personal Hyprland preferences
- `hyde/config.toml` - HyDE main configuration
- `waybar/config` - Status bar configuration (in waybar/layouts/)
