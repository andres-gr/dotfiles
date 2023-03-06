#!/bin/bash

$(rm -rf "$HOME/Library/Application Support/cDock")

$(mkdir "$HOME/Library/Application Support/cDock")

$(cp -rf "$DOTFILES/cDock/themes" "$HOME/Library/Application Support/cDock")
$(cp -rf "$DOTFILES/cDock/backups" "$HOME/Library/Application Support/cDock")
