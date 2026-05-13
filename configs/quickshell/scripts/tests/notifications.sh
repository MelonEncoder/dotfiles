#!/usr/bin/env bash
# Notification test suite — runs each case with a short delay between them.
# Usage: ./notifications.sh [test-name]
#   If no argument is given, all tests run in sequence.

DELAY=2
IMAGE_PNG="/usr/share/pixmaps/archlinux-logo.png"
IMAGE_LARGE="/usr/share/icons/hicolor/48x48/apps/chromium.png"

run() {
    local name="$1"; shift
    echo "→ $name"
    "$@"
    sleep "$DELAY"
}

case "${1:-all}" in

basic)
    run "Basic — summary only" \
        notify-send -a "Test" "Hello"
    ;;

body)
    run "Body text" \
        notify-send -a "Test" "Message with body" "This is the body of the notification. It provides extra detail below the summary."
    ;;

long-body)
    run "Long body (truncated at max_body_lines)" \
        notify-send -a "Test" "Long body" \
"Line one of a very long notification body.
Line two keeps going with more content.
Line three adds even more text here.
Line four should be the last visible line.
Line five should be clipped by max_body_lines."
    ;;

urgency-low)
    run "Urgency — low" \
        notify-send -a "Test" -u low "Low urgency" "Styled with the low-urgency accent colour."
    ;;

urgency-critical)
    run "Urgency — critical (no auto-expire)" \
        notify-send -a "Test" -u critical "Critical!" "This notification should not auto-expire."
    ;;

icon)
    run "App icon" \
        notify-send -a "Test" -i "archlinux-logo" "With app icon" "The icon appears in the top-left corner of the card."
    ;;

image)
    run "Inline image (image-path hint)" \
        notify-send -a "Test" "Notification with image" "An image should appear below this body text." \
        -h "string:image-path:$IMAGE_PNG"
    ;;

image-large)
    run "Inline image — large file (capped at image_max_height)" \
        notify-send -a "Test" "Large image" "Image should be capped at max height." \
        -h "string:image-path:$IMAGE_LARGE"
    ;;

actions)
    run "Actions — two buttons" \
        notify-send -a "Test" "Notification with actions" "Click a button to invoke it." \
        -A "reply=Reply" -A "archive=Archive"
    ;;

actions-icons)
    run "Actions with icons (action-icons hint)" \
        notify-send -a "Test" "Action icons" "Buttons should show XDG icons when hasActionIcons is true." \
        -h "bool:action-icons:true" \
        -A "media-playback-start=Play" \
        -A "media-playback-stop=Stop"
    ;;

actions-dismiss-filtered)
    run "Actions — dismiss/close filtered out" \
        notify-send -a "Test" "Filtered actions" "The Dismiss and Close buttons should not appear." \
        -A "open=Open" -A "dismiss=Dismiss" -A "close=Close"
    ;;

no-expire)
    run "No auto-expire (t=0)" \
        notify-send -a "Test" -t 0 "Persistent toast" "This notification should stay until dismissed."
    ;;

fast-expire)
    run "Fast expire (t=2000ms)" \
        notify-send -a "Test" -t 2000 "Fast expire" "This toast should disappear after 2 seconds."
    ;;

stack)
    echo "→ Stack — 4 rapid notifications"
    notify-send -a "Alpha"   "Stack #1" "First in the stack"
    sleep 0.3
    notify-send -a "Beta"    "Stack #2" "Second in the stack"
    sleep 0.3
    notify-send -a "Gamma"   "Stack #3" "Third in the stack"
    sleep 0.3
    notify-send -a "Delta"   "Stack #4" "Fourth in the stack"
    sleep "$DELAY"
    ;;

full)
    run "Full — icon + image + actions + body" \
        notify-send -a "Full Test" -i "archlinux-logo" \
        "Full notification" "All features active: icon, image, body, and action buttons." \
        -h "string:image-path:$IMAGE_PNG" \
        -A "open=Open" -A "snooze=Snooze"
    ;;

all)
    "$0" basic
    "$0" body
    "$0" long-body
    "$0" urgency-low
    "$0" urgency-critical
    "$0" icon
    "$0" image
    "$0" image-large
    "$0" actions
    "$0" actions-icons
    "$0" actions-dismiss-filtered
    "$0" no-expire
    "$0" fast-expire
    "$0" stack
    "$0" full
    ;;

*)
    echo "Unknown test: $1"
    echo "Available: basic body long-body urgency-low urgency-critical icon image image-large actions actions-icons actions-dismiss-filtered no-expire fast-expire stack full all"
    exit 1
    ;;
esac
