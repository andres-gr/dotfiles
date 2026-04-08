#!/bin/env bash

if [ $(($RANDOM % 5)) -eq 0 ]; then
  SHINY='-s'
else
  SHINY=''
fi

# pokego $SHINY -r 1,2 | awk 'NR==1 { color = /shiny/ ? "\033[1;33m" : "\033[1;37m"; printf "%s✦ %s\033[0m\n", color, $0; next } { print }'

pokego $SHINY -r 1,2 | awk '
# 1. Find the first non-empty line to use as the name/header
!header && /\S/ {
    color = /shiny/ ? "\033[1;33m" : "\033[1;37m";
    header = sprintf("  %s✦ %s\033[0m", color, $0);
    next
}
# 2. Print everything else (the sprite)
{ print }
# 3. Print the header at the very end
END { if (header) print "\n" header }'
