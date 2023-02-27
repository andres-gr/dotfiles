#!/bin/bash

$(rm -rf "$HOME/Library/Application Support/cDock")

$(mkdir "$HOME/Library/Application Support/cDock")
$(mkdir "$HOME/Library/Application Support/cDock/themes")
$(mkdir "$HOME/Library/Application Support/cDock/backups")
$(mkdir "$HOME/Library/Application Support/cDock/themes/10.16 - Big Sur")

$(ln -sf "$HOME/Documents/cDock/10.16 - Big Sur.plist" "$HOME/Library/Application Support/cDock/themes/10.16 - Big Sur")
$(ln -sf "$HOME/Documents/cDock/com.apple.dock.26 February 2023, 6:31:02 p.m. CST.plist" "$HOME/Library/Application Support/cDock/backups")
