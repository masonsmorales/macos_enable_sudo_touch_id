#!/bin/bash

echo_enabled() {
    echo "Touch ID has been successfully enabled for sudo."
}

echo_already_enabled() {
    echo "Touch ID has already been enabled for sudo"
}
# Function to update file for macOS Ventura (13.x)
update_file_ventura() {
    local file="/etc/pam.d/sudo"
    local line="auth       sufficient     pam_tid.so"

    if ! grep -q "$line" "$file" 2>/dev/null; then
        nl='
'
        sudo sed -i '' '/# sudo: auth account password session/a\
'"$line\\${nl}" "$file"
        if [ $? -eq 0 ]; then
            echo_enabled
        else
            echo "Unable to enable Touch ID for sudo. Error adding line to $file."
            exit 1
        fi
    else
        echo_already_enabled
    fi
}

# General function to update file for other versions
update_file_sonoma() {
    local file="/etc/pam.d/sudo_local"
    local line="auth       sufficient     pam_tid.so"

    if [ ! -f "$file" ]; then
        echo "$file does not exist. Creating file and adding line."
        echo "$line" | sudo tee "$file" \
        && echo_enabled
    elif ! grep -q "$line" "$file" 2>/dev/null; then
        echo "$line" | sudo tee -a "$file" \
        && echo_enabled
    else
        echo "Line already exists in $file."
        return
    fi

    if [ $? -neq 0 ]; then
        echo "Error adding line to $file."
        exit 1
    fi
}

# Function to check macOS version
check_macos_version() {
    local os_version
    os_version=$(sw_vers -productVersion)
    if [[ "$os_version" == 13.* ]]; then
        update_file_ventura
    elif [[ "$os_version" == 14.* ]]; then
        update_file_sonoma
    else
        echo "This script is intended for macOS Ventura (13.*) and Sonoma (14.*)."
    fi
}

# Run the script
check_macos_version
