# Proton Shortcut Creator

A simple yet powerful bash script for Linux users to create `.desktop` shortcuts for non-Steam Windows applications, allowing them to run with Proton without needing the Steam client to be open.

Note: This will **not** work if Steam is installed as a Flatpak.

## Features

  - **Interactive & User-Friendly:** A guided command-line interface walks you through the process.
  - **Auto-Discovery:** Automatically detects your installed custom Proton versions.
  - **Prefix Management:** Lists existing Proton prefixes (`compatdata`) and allows you to use them or generate a new ID for a clean prefix.
  - **Custom Launch Options:** Easily add command-line arguments and environment variables (like `gamemoderun`, `WINEDLLOVERRIDES`, etc.) just like you would in Steam.
  - **Automated File Creation:** Generates a standard `.desktop` file on your desktop.
  - **Application Menu Integration:** Automatically creates a symbolic link to `~/.local/share/applications` so your new shortcut appears in your system's start menu.

## Prerequisites

1.  **A Standard Steam Installation:** The script assumes Steam is installed in the default location (`~/.steam/steam`).
2.  **Custom Proton Version (like GE-Proton):** This script is designed for custom Proton builds. The easiest way to install and manage these is with the **ProtonUp-Qt** utility.
      - Download and run [ProtonUp-Qt](https://github.com/DavidoTek/ProtonUp-Qt).
      - When you add a new Proton version, make sure you choose to **install it for "Steam"**. This will place the files in the correct directory for the script to find them.

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

      - The name of your shortcut.
      - A comment (optional).
      - Which Proton version to use (from a list it finds).
      - Which `compatdata` prefix to use (from a list, or you can create a new one).
      - The full path to the application's `.exe` file.
      - Any custom options for the game (optional).
      - The full path to an icon file (optional).

## How to Delete a Shortcut

Deleting a shortcut is as simple as deleting the file from your desktop.

The script creates two items: the main `.desktop` file on your desktop and a symbolic link (symlink) to that file in your application menu folder. Because the entry in your start menu is only a link, you just need to **delete the shortcut file from your desktop**.

Once the original file is gone, the symlink in the start menu becomes broken. Your desktop environment will automatically detect this and remove the icon from your application menu, usually after you log out and log back in, or after a system restart.

## Understanding Launch Options

The script will ask for "Launch Options". This allows you to add special commands or variables, just like you would in the Steam client.

**How it works:**

  - You can enter environment variables (like `WINEDLLOVERRIDES="winmm=n,b"`) or wrapper commands (like `gamemoderun`).
  - You **must include the `%command%` placeholder** in your options. This special text tells the script exactly where to insert the main command that runs the game.
  - The script replaces `%command%` with the correct Proton execution command behind the scenes to create a valid shortcut.

**Examples:**

  - To run the game with MangoHud, you would enter:

    ```
    mangohud %command%
    ```

  - To use a custom Wine DLL override, you would enter:

    ```
    WINEDLLOVERRIDES="dinput8=n,b" %command%
    ```

  - To pass an argument directly to the game's executable, you would enter:

    ```
    %command% -nolauncher
    ```

If you don't need any special options, you can simply press **Enter** to skip this step.

## How It Works

The script is designed to be portable and should work for anybody using linux. It uses the `$HOME` environment variable to locate the necessary files and directories.

  - **Proton Versions:** It searches for Proton installations in:
    `~/.local/share/Steam/compatibilitytools.d/`

  - **Proton Prefixes (`compatdata`):** It looks for your existing Proton prefixes (the folders that store application data and act like a mini C: drive) in:
    `~/.steam/steam/steamapps/compatdata/`

  - **Shortcut Location:** The final `.desktop` file is created on your desktop at:
    `~/Desktop/`

  - **Application Menu Link:** A symbolic link is created from the desktop file to your local applications folder to ensure it appears in your start menu:
    `~/.local/share/applications/`
