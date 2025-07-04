#!/bin/bash

# ==============================================================================
# Proton Shortcut Creator
#
# Author: Cyquna
# Description: This script automates the creation of .desktop shortcuts for
#              running non-Steam Windows applications with a specific Proton
#              version, without needing the Steam client to be running.
# Version: 1.1
# ==============================================================================

# --- Configuration ---
# These paths are based on a standard Steam installation on Linux.
# The script will use the current user's home directory automatically.
STEAM_INSTALL_PATH="$HOME/.steam/steam"
COMPATDATA_BASE_PATH="$STEAM_INSTALL_PATH/steamapps/compatdata"
PROTON_TOOLS_PATH="$HOME/.local/share/Steam/compatibilitytools.d"
DESKTOP_PATH="$HOME/Desktop"
APPLICATIONS_PATH="$HOME/.local/share/applications"

# --- Helper Functions ---

# Function to print a formatted header
print_header() {
    echo "================================================"
    echo "  $1"
    echo "================================================"
    echo
}

# Function to handle user cancellation
check_exit() {
    if [[ "$1" == "q" || "$1" == "Q" ]]; then
        echo "Operation cancelled by user. Exiting."
        exit 0
    fi
}

# --- Main Script Logic ---

# Ensure required directories exist
if [ ! -d "$PROTON_TOOLS_PATH" ] || [ ! -d "$COMPATDATA_BASE_PATH" ]; then
    echo "Error: Could not find required Steam directories."
    echo "Please ensure the following paths exist:"
    echo "Proton Tools: $PROTON_TOOLS_PATH"
    echo "Compatdata: $COMPATDATA_BASE_PATH"
    exit 1
fi

clear
print_header "Proton Shortcut Creator"

# 1. Get Application Name
echo "Enter the name for the application shortcut."
read -p "Application Name: " APP_NAME
while [ -z "$APP_NAME" ]; do
    echo "Application name cannot be empty."
    read -p "Application Name: " APP_NAME
done
echo

# 2. Get Application Comment
echo "Enter a brief comment for the shortcut (optional)."
read -p "Comment: " APP_COMMENT
echo

# 3. Select Proton Version
print_header "Select a Proton Version Installed by ProtonUp-Qt - Wine/Proton Installer"
echo "Searching for Proton versions in: $PROTON_TOOLS_PATH"
echo "Enter 'q' to quit at any time."
echo

# Store proton versions in an array
mapfile -t proton_versions < <(find "$PROTON_TOOLS_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort -V)

if [ ${#proton_versions[@]} -eq 0 ]; then
    echo "No Proton versions found in $PROTON_TOOLS_PATH"
    exit 1
fi

# Display numbered list of proton versions
for i in "${!proton_versions[@]}"; do
    echo "[$i] ${proton_versions[$i]}"
done
echo

# Get user selection
while true; do
    read -p "Enter the number for the Proton version to use: " proton_choice
    check_exit "$proton_choice"
    if [[ "$proton_choice" =~ ^[0-9]+$ ]] && [ "$proton_choice" -ge 0 ] && [ "$proton_choice" -lt ${#proton_versions[@]} ]; then
        SELECTED_PROTON_DIR="${proton_versions[$proton_choice]}"
        PROTON_RUN_PATH="$PROTON_TOOLS_PATH/$SELECTED_PROTON_DIR/proton"
        echo "You selected: $SELECTED_PROTON_DIR"
        break
    else
        echo "Invalid selection. Please enter a number from the list."
    fi
done
echo

# 4. Select Compatdata Directory
print_header "Select a Compatdata Directory"
echo "These are the prefix directories that store Windows application data."
echo "If you're setting up a new app, you might need to create a new random ID."
echo

# Store compatdata directories in an array
mapfile -t compat_dirs < <(find "$COMPATDATA_BASE_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort -n)

# Display numbered list of compatdata directories
for i in "${!compat_dirs[@]}"; do
    echo "[$i] ${compat_dirs[$i]}"
done
echo "[n] Create a new compatdata directory (generates a random ID)"
echo

# Get user selection
while true; do
    read -p "Enter the number for the compatdata directory, or 'n' for new: " compat_choice
    check_exit "$compat_choice"
    if [[ "$compat_choice" == "n" || "$compat_choice" == "N" ]]; then
        # Generate a random 10-digit number for the new compatdata directory
        COMPATDATA_ID=$((1000000000 + RANDOM % 9000000000))
        echo "Generated new compatdata ID: $COMPATDATA_ID"
        # The directory will be created automatically by Proton on first launch
        break
    elif [[ "$compat_choice" =~ ^[0-9]+$ ]] && [ "$compat_choice" -ge 0 ] && [ "$compat_choice" -lt ${#compat_dirs[@]} ]; then
        COMPATDATA_ID="${compat_dirs[$compat_choice]}"
        echo "You selected: $COMPATDATA_ID"
        break
    else
        echo "Invalid selection. Please enter a number from the list or 'n'."
    fi
done
echo

# 5. Get Executable Path
print_header "Enter Executable Path"
echo "Provide the full, absolute path to the .exe file."
echo "Example: /home/$USER/Games/MyGame/Game.exe"
read -e -p "Executable Path: " EXE_PATH
check_exit "$EXE_PATH"
while [ ! -f "$EXE_PATH" ]; do
    echo "Error: File not found at '$EXE_PATH'."
    read -e -p "Please enter a valid path to the .exe file: " EXE_PATH
    check_exit "$EXE_PATH"
done
echo

# 6. Get Launch Options (NEW SECTION)
print_header "Enter Launch Options (Optional)"
echo "Enter launch options as you would in Steam."
echo "Use %command% as a placeholder for the game executable."
echo "Example: WINEDLLOVERRIDES=\"winmm=n,b\" %command% -fullscreen"
echo "Press Enter to skip."
read -p "Launch Options: " LAUNCH_OPTIONS
echo

# 7. Get Icon Path
print_header "Enter Icon Path"
echo "Provide the full, absolute path to the icon file (.png, .ico)."
echo "This is optional. Press Enter to skip and use a default icon."
read -e -p "Icon Path (optional): " ICON_PATH
check_exit "$ICON_PATH"
if [ -z "$ICON_PATH" ]; then
    ICON_PATH="wine" # Default icon
    echo "No icon path provided. Using default 'wine' icon."
elif [ ! -f "$ICON_PATH" ]; then
    echo "Warning: Icon file not found at '$ICON_PATH'. Using default 'wine' icon."
    ICON_PATH="wine"
fi
echo

# --- Build and Create Files ---

# Define the full data path for the compatdata directory
STEAM_COMPAT_DATA_PATH="$COMPATDATA_BASE_PATH/$COMPATDATA_ID"

# The core command that %command% will be replaced with
CORE_COMMAND="\"$PROTON_RUN_PATH\" run \"$EXE_PATH\""

# If user provided launch options, use them. Otherwise, default to just the command.
if [ -n "$LAUNCH_OPTIONS" ]; then
    # Replace %command% placeholder with the actual core command
    FULL_PROTON_COMMAND="${LAUNCH_OPTIONS//%command%/$CORE_COMMAND}"
else
    # If no options, the command is just the core command
    FULL_PROTON_COMMAND="$CORE_COMMAND"
fi

# Construct the final Exec command string for the .desktop file
EXEC_COMMAND="/bin/bash -c 'STEAM_COMPAT_CLIENT_INSTALL_PATH=\"$STEAM_INSTALL_PATH\" STEAM_COMPAT_DATA_PATH=\"$STEAM_COMPAT_DATA_PATH\" $FULL_PROTON_COMMAND'"

# Sanitize App Name for the filename
FILENAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9._-]/_/g').desktop
DESKTOP_FILE_PATH="$DESKTOP_PATH/$FILENAME"

# Create .desktop file content using a heredoc
cat > "$DESKTOP_FILE_PATH" << EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_COMMENT
Exec=$EXEC_COMMAND
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Game;
EOF

# Make the desktop file executable
chmod +x "$DESKTOP_FILE_PATH"

# Create symlink to applications folder for start menu integration
SYMLINK_PATH="$APPLICATIONS_PATH/$FILENAME"
if [ -L "$SYMLINK_PATH" ]; then
    echo "Existing symlink found. Removing it before creating a new one."
    rm "$SYMLINK_PATH"
fi
ln -s "$DESKTOP_FILE_PATH" "$SYMLINK_PATH"

# --- Final Output ---
print_header "Success! ✅"
echo "Shortcut created on your desktop:"
echo "  -> $DESKTOP_FILE_PATH"
echo
echo "A link has been added to your applications menu:"
echo "  -> $SYMLINK_PATH"
echo
echo "Thanks for using the script!"
