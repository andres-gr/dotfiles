# 99-local.zsh — machine-local overrides, intentionally empty in repo
# Copy this file to ~/.config/zsh/conf.d/99-local.zsh and add private settings there if you want.

export JAVA_HOME="${JAVA_HOME:-/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home}"
export ESLINT_USE_FLAT_CONFIG=false

export ANDROID_HOME="${jNDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
