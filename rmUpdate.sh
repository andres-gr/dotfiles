#!/bin/zsh

defaults delete com.apple.systempreferences AttentionPrefBundleIDs
defaults delete com.apple.systempreferences DidShowPrefBundleIDs
killall Dock

