# Proton Shortcut Creator

A simple yet powerful bash script for Linux users to create `.desktop` shortcuts for non-Steam Windows applications, allowing them to run with Proton without needing the Steam client to be open.

Note: This will **not** work if Steam is installed as a Flatpak.

## Features

-   **Interactive & User-Friendly:** A guided command-line interface walks you through the process.
-   **Auto-Discovery:** Automatically detects your installed custom Proton versions.
-   **Prefix Management:** Lists existing Proton prefixes (`compatdata`) and allows you to use them or generate a new ID for a clean prefix.
-   **Automated File Creation:** Generates a standard `.desktop` file on your desktop.
-   **Application Menu Integration:** Automatically creates a symbolic link to `~/.local/share/applications` so your new shortcut appears in your system's start menu (e.g., GNOME Activities, KDE Start Menu).

## Prerequisites

1.  **A Standard Steam Installation:** The script assumes Steam is installed in the default location (`~/.steam/steam`).
2.  **Custom Proton Version (like GE-Proton):** This script is designed for custom Proton builds. The easiest way to install and manage these is with the **ProtonUp-Qt** utility.

    -   Download and run [ProtonUp-Qt](https://github.com/DavidoTek/ProtonUp-Qt).
    -   When you add a new Proton version, make sure you choose to **install it for "Steam"**. This will place the files in the correct directory for the script to find them.

## How to Use

1.  **Download the Script**
    Download the `protonshortcut.sh` script to your computer.

2.  **Make it Executable**
    Open a terminal, navigate to the directory where you saved the script, and run the following command:
    ```bash
    chmod +x protonshortcut.sh
    ```

3.  **Run the Script**
    Execute the script from your terminal:
    ```bash
    ./protonshortcut.sh
    ```
    The script will then ask you for the following information:
    -   The name of your shortcut.
    -   A comment (optional).
    -   Which Proton version to use (from a list it finds).
    -   Which `compatdata` prefix to use (from a list, or you can create a new one).
    -   The full path to the application's `.exe` file.
    -   The full path to an icon file (optional).

## How It Works

The script is designed to be portable and should work for anybody using linux. It uses the `$HOME` environment variable to locate the necessary files and directories.

-   **Proton Versions:** It searches for Proton installations in:
    `~/.local/share/Steam/compatibilitytools.d/`

-   **Proton Prefixes (`compatdata`):** It looks for your existing Proton prefixes (the folders that store application data and act like a mini C: drive) in:
    `~/.steam/steam/steamapps/compatdata/`

-   **Shortcut Location:** The final `.desktop` file is created on your desktop at:
    `~/Desktop/`

-   **Application Menu Link:** A symbolic link is created from the desktop file to your local applications folder to ensure it appears in your start menu:
    `~/.local/share/applications/`
