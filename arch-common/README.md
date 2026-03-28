# arch-common

This stow package contains configurations that work across any Arch-based distro (Arch Linux, CachyOS, EndeavourOS, etc.) and any window manager/compositor.

## Contents

### `.config/`
| Directory/File | Description |
|----------------|-------------|
| `fontconfig/` | System-wide font configuration |
| `environment.d/wlroots.conf` | wlroots DRM device configuration |
| `kdeglobals` | KDE global settings (works with Dolphin, etc.) |
| `xdg-terminals.list` | Terminal emulator preferences |
| `zoomus.conf` | Zoom client configuration |
| `chromium-flags.conf` | Chromium browser flags |
| `zsh/functions/pkgs.zsh` | Zsh package helper functions |

### `.local/`
| Directory/File | Description |
|----------------|-------------|
| `bin/fix-slack-share` | Fix for Slack screen sharing |
| `bin/media-notify.sh` | Media notification script |
| `bin/spotify-simple` | Simple Spotify controls |
| `share/applications/*.desktop` | Desktop entries (lock, reboot, suspend, etc.) |

## Usage

This package is always included when installing on Arch-based systems, regardless of which window manager you use.

## Requirements

- Arch Linux or derivative (CachyOS, EndeavourOS, etc.)
- Zsh (for zsh functions)
- Fontconfig (for font settings)
