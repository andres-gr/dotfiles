info=$(yabai -m query --spaces --display)
first=$(echo $info | jq '.[0]."has-focus"')

if [[ $first == "false" ]]; then
  yabai -m window --space prev; yabai -m space --focus prev
else
  yabai -m window --space $(echo $info | jq '.[-1].index'); yabai -m space --focus $(echo $info | jq '.[-1].index')
fi
