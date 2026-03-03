# ~/.config/zsh/.zshrc

# --------------------------------------------------
# Interactive guard
# --------------------------------------------------
[[ $- != *i* ]] && return

# --------------------------------------------------
# Load modular configuration
# --------------------------------------------------
for file in "$ZDOTDIR"/conf.d/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done

# --------------------------------------------------
# Load plugins (separate layer)
# --------------------------------------------------
[[ -r "$ZDOTDIR/plugins.zsh" ]] && source "$ZDOTDIR/plugins.zsh"

# bun completions
[ -s "/Users/andres/.bun/_bun" ] && source "/Users/andres/.bun/_bun"
