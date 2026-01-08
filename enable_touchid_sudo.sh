#!/bin/bash

# Verify we're running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is intended for macOS only."
    exit 1
fi

echo_enabled() {
    echo "Touch ID has been successfully enabled for sudo."
}

echo_already_enabled() {
    echo "Touch ID has already been enabled for sudo."
}

update_sudo_local() {
    local file="/etc/pam.d/sudo_local"
    local line="auth       sufficient     pam_tid.so"

    if [ ! -f "$file" ]; then
        echo "$file does not exist. Creating file and adding line."
        echo "$line" | sudo tee "$file" > /dev/null \
            && echo_enabled
    elif ! grep -q "$line" "$file" 2>/dev/null; then
        echo "$line" | sudo tee -a "$file" > /dev/null \
            && echo_enabled
    else
        echo_already_enabled
        return
    fi

    if [ $? -ne 0 ]; then
        echo "Error adding line to $file."
        exit 1
    fi
}

update_sudo_local
