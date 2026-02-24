# zsh/.zshrc — minimal loader
# Load configuration modules
for file in "$ZDOTDIR/conf.d/"*.zsh; do
  [ -r "$file" ] && source "$file"
done

# Load categorized functions
for file in "$ZDOTDIR/functions/"*.zsh; do
  [ -r "$file" ] && source "$file"
done

# Load plugin manager wrapper (antidote preferred)
[ -r "$ZDOTDIR/plugins.zsh" ] && source "$ZDOTDIR/plugins.zsh"
