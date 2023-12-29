#!/usr/bin/env python3
"""
This script provides a command-line interface to manage and execute a customizable menu of commands.
"""

import argparse
import json
import subprocess
import os
import sys

home_directory = os.path.expanduser("~")
config_file = os.path.join(home_directory, "config.json")
colors = [f"\033[{color_code}m" for color_code in ([0] + list(range(31, 38)) + list(range(90, 98)))]

def get_color(index):
    """Return the color code for a given index."""
    return colors[(index + 1) % len(colors)]

def default_config():
    """Return the default configuration for the menu."""
    return {
        "chrome_executable_path": "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe",
        "chrome_executable_path_chrome_os": "xdg-open",
        "editor": "vi",
        "display_items_per_line": 4,
        "menu_item_length": 20,
        "menu_items": [
            ["google keep", "https://keep.google.com/u/0/#home"],
            ["google gmail", "https://mail.google.com/mail/u/0/#inbox"],
            ["google calendar", "https://calendar.google.com/calendar/u/0/r"]
        ]
    }

def handle_keyboard_interrupt():
    """Handle a keyboard interrupt and exit the program."""
    print("Keyboard interrupt detected. Exiting...")
    sys.exit(0)

def load_config():
    """Load the configuration from a file, or create a default one if not found."""
    try:
        with open(config_file, "r", encoding="utf-8") as file:
            return json.load(file)
    except FileNotFoundError:
        print("Configuration file not found, creating a new one.")
        config = default_config()
        save_config(config)
        return config
    except json.JSONDecodeError:
        print("Error parsing the configuration file.")
        return None

def save_config(config):
    """Save the configuration to a file."""
    with open(config_file, "w", encoding="utf-8") as file:
        json.dump(config, file, indent=4)

def display_menu(config):
    """Display the menu items from the configuration."""
    for index, item in enumerate(config['menu_items']):
        color = get_color(index)
        print(f"{color}{index+1:2}. {item[0].ljust(config['menu_item_length'])}{colors[0]}", end="  ")
        if (index + 1) % config['display_items_per_line'] == 0 or index == len(config['menu_items']) - 1:
            print()

def add_menu_item(config, new_item, new_command):
    """Add a new menu item to the configuration."""
    config["menu_items"].append([new_item, new_command])
    save_config(config)
    print(f"{new_item} added to the menu.")

def remove_menu_item(config, identifier):
    """Remove a menu item from the configuration by index or search string."""
    if str(identifier).isdigit():
        index = int(identifier) - 1
        if 0 <= index < len(config["menu_items"]):
            removed_item = config["menu_items"].pop(index)[0]
            save_config(config)
            print(f"{removed_item} removed from the menu, and saved config.")
        else:
            print("Invalid index.")
    else:
        search_term = identifier.lower()
        for index, item in enumerate(config["menu_items"]):
            if search_term in item[0].lower():
                removed_item = config["menu_items"].pop(index)[0]
                save_config(config)
                print(f"{removed_item} removed from the menu, and saved config.")
                return
        print("Item not found.")

def change_menu_item(config, index, new_item, new_command):
    """Change an existing menu item in the configuration."""
    index = int(index) - 1
    if 0 <= index < len(config["menu_items"]):
        config["menu_items"][index] = [new_item, new_command]
        print(f"Menu item {index+1} changed to {new_item}.")
        save_config(config)
    else:
        print("Invalid input.")

def change_items_per_line(config, new_value):
    """Change the number of items per line in the menu display."""
    if new_value > 0:
        config["display_items_per_line"] = new_value
        save_config(config)
    else:
        print("Invalid input. Please provide a positive integer value for the number of items per line.")

def edit_config(config):
    """Open the configuration file in an editor for manual editing."""
    editor_command = [config.get('editor', 'vi'), config_file]
    subprocess.run(editor_command)
    config = load_config()

def search_items(config, term):
    """Search for menu items matching a given term."""
    search_term = term.lower()
    menu_items = config["menu_items"]

    if search_term.isdigit():
        item_number = int(search_term)
        if 1 <= item_number <= len(menu_items):
            index = item_number - 1
            item, command = menu_items[index]
            run_command(index, item, command, config)
            return

    found_items = [(i, item[0], item[1]) for i, item in enumerate(menu_items, start=1) if search_term in item[0].lower()]

    if not found_items:
        print("No matching items found.")
        return

    if len(found_items) == 1:
        run_command(*found_items[0], config)
        return

    print("\nSearch Results:")
    for index, item, _ in found_items:
        color = get_color(index)
        print(f"{color}{index:2}. {item.ljust(config['menu_item_length'])}{colors[0]}")

def run_command(index, item, command, config):
    """Execute a command associated with a menu item."""
    print(f"You chose option {index}: {item}")
    if command.startswith("http"):
        browser_cmd = config["chrome_executable_path"]
        url = command
        try:
            subprocess.run([browser_cmd, url], check=True)
        except FileNotFoundError:
            print(f"Browser '{browser_cmd}' not found.")
        except subprocess.CalledProcessError:
            print("Failed to open the URL.")
    else:
        cmd = command.split()
        try:
            subprocess.run(cmd, check=True)
        except FileNotFoundError:
            print(f"Command '{cmd}' not found.")
        except subprocess.CalledProcessError as e:
            print(f"Command failed with exit status {e.returncode}.")
        except KeyboardInterrupt:
            handle_keyboard_interrupt()

    print("Command execution completed.")

def main():
    """Main function to parse arguments and handle the menu logic."""
    parser = argparse.ArgumentParser()
    parser.add_argument('search', nargs='?', help='search for a menu item or provide item number')
    parser.add_argument('-a', '--add', nargs=2, metavar=('ITEM', 'COMMAND'), help='add a new menu item')
    parser.add_argument('-r', '--remove', metavar='IDENTIFIER', help='remove a menu item by index or name')
    parser.add_argument('-c', '--change', nargs=3, metavar=('INDEX', 'ITEM', 'COMMAND'), help='change a menu item')
    parser.add_argument('-n', '--newline', type=int, metavar='VALUE', help='change number of items per line')
    parser.add_argument('-e', '--edit', action='store_true', help='open the configuration file in an editor')

    args = parser.parse_args()
    config = load_config()
    if config is None:
        sys.exit()

    if args.search:
        search_items(config, args.search)
    elif args.add:
        add_menu_item(config, *args.add)
    elif args.remove:
        remove_menu_item(config, args.remove)
    elif args.change:
        change_menu_item(config, *args.change)
    elif args.newline:
        change_items_per_line(config, args.newline)
    elif args.edit:
        edit_config(config)
    else:
        display_menu(config)

if __name__ == "__main__":
    main()
