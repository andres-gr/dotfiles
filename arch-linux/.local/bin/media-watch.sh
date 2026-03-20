#!/usr/bin/env bash
# media-watch.sh — daemon that watches for track changes and sends notifications
# Started via exec-once in userprefs.conf.
# Uses playerctl --follow to block and react to metadata changes.
# Sends via media-notify.sh so notifications are transient (no history).

# Wait for playerctld to be available
sleep 2

playerctl --follow --player="%any" metadata --format "{{playerName}}|{{title}}|{{artist}}|{{mpris:artUrl}}|{{status}}" 2>/dev/null \
| while IFS='|' read -r PLAYER TITLE ARTIST ART_URL STATUS; do
    # Only notify on Playing status with an actual title
    [[ "$STATUS" != "Playing" ]] && continue
    [[ -z "$TITLE" ]] && continue

    BODY="${TITLE}"
    [[ -n "$ARTIST" ]] && BODY="${ARTIST} — ${TITLE}"

    # Fetch album art if available
    ICON="media-playback-start"
    if [[ -n "$ART_URL" ]]; then
        ART_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/media-notify"
        mkdir -p "$ART_CACHE_DIR"
        ART_HASH=$(printf '%s' "$ART_URL" | sha1sum | cut -c1-16)
        ART_FILE="$ART_CACHE_DIR/${ART_HASH}.jpg"
        if [[ ! -f "$ART_FILE" ]]; then
            curl -fsSL --max-time 3 -o "$ART_FILE" "$ART_URL" 2>/dev/null \
                || rm -f "$ART_FILE"
        fi
        [[ -f "$ART_FILE" ]] && ICON="$ART_FILE"
    fi

    notify-send \
        --app-name "media-notify" \
        --replace-id 9 \
        --urgency low \
        --expire-time 3000 \
        --icon "$ICON" \
        "Now Playing" \
        "$BODY"
done
