#!/bin/bash

# Automator script
#
# #!/bin/bash
#
# export PATH="$PATH:/usr/local/bin/"
# export DOTFILES="$HOME/devel/dotfiles"
#
# resetCdock.sh && open -a cDock

$(rm -rf "$HOME/Library/Application Support/cDock")

$(mkdir "$HOME/Library/Application Support/cDock")

$(cp -rf "$DOTFILES/cDock/themes" "$HOME/Library/Application Support/cDock")
$(cp -rf "$DOTFILES/cDock/backups" "$HOME/Library/Application Support/cDock")
