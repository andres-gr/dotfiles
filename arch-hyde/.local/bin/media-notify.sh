#!/usr/bin/env bash
# media-notify.sh — send a transient notification on media player state changes
# Called from keybindings.conf after playerctl commands.
# Uses app-name "media-notify" so swaync marks these as transient (no history).

# Give playerctl a moment to update state after the command
sleep 0.3

PLAYER="${1:-}"
PLAYER_ARG="${PLAYER:+--player=$PLAYER}"

STATUS=$(playerctl $PLAYER_ARG status 2>/dev/null) || exit 0
TITLE=$(playerctl $PLAYER_ARG metadata title 2>/dev/null)
ARTIST=$(playerctl $PLAYER_ARG metadata artist 2>/dev/null)

case "$STATUS" in
    Playing)
        ICON="media-playback-start"
        SUMMARY="Now Playing"
        ;;
    Paused)
        ICON="media-playback-pause"
        SUMMARY="Paused"
        ;;
    Stopped)
        ICON="media-playback-stop"
        SUMMARY="Stopped"
        exit 0
        ;;
    *)
        exit 0
        ;;
esac

BODY="${TITLE}"
[[ -n "$ARTIST" ]] && BODY="${ARTIST} — ${TITLE}"

notify-send \
    --app-name "media-notify" \
    --replace-id 9 \
    --urgency low \
    --expire-time 3000 \
    --icon "$ICON" \
    "$SUMMARY" \
    "$BODY"
