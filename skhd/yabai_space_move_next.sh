info=$(yabai -m query --spaces --display)
last=$(echo $info | jq '.[-1]."has-focus"')

if [[ $last == "false" ]]; then
  yabai -m window --space next; yabai -m space --focus next
else
  yabai -m window --space $(echo $info | jq '.[0].index'); yabai -m space --focus $(echo $info | jq '.[0].index')
fi
