#!/usr/bin/env python3

import argparse
import json
import subprocess
import os
import sys

home_directory = os.path.expanduser("~")
config_file = os.path.join(home_directory, "config.json")
colors = [f"\033[{i}m" for i in ([0] + list(range(31, 38)) + list(range(90, 98)))]

def get_color(index):
    return colors[(index + 1) % len(colors)]

def default_config():
    '''default config.json if no config was found'''
    config = {
        "chrome_executable_path": "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe",
        "chrome_executable_path_chrome_os": "xdg-open",
        "editor": "vi",
        "display_items_per_line": 4,
        "menu_item_length": 20,
        "menu_items": [
            ["google keep","https://keep.google.com/u/0/#home"],
            ["google gmail","https://mail.google.com/mail/u/0/#inbox"],
            ["google calendar","https://calendar.google.com/calendar/u/0/r"]
        ]
    }
    return config

def handle_keyboard_interrupt():
    print("Keyboard interrupt detected. Exiting...")
    # Additional cleanup or custom logic if needed
    sys.exit(0)

def load_config():
    try:
        with open(config_file, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        print("Configuration file not found, creating a new one.")
        config = default_config()
        save_config(config)
        return config
    except json.JSONDecodeError:
        print("Error parsing the configuration file.")
        return None

def save_config(config):
    with open(config_file, "w") as f:
        json.dump(config, f, indent=4)

def display_menu(config):
    for index, item in enumerate(config['menu_items']):
        color = get_color(index)
        print(f"{color}{index+1:2}. {item[0].ljust(config['menu_item_length'])}{colors[0]}", end="  ")
        if (index + 1) % config['display_items_per_line'] == 0 or index == len(config['menu_items']) - 1:
            print()

def add_menu_item(config, new_item, new_command):
    config["menu_items"].append((new_item, new_command))
    save_config(config)
    print(f"{new_item} added to the menu.")

def remove_menu_item(config, index):
    index -= 1
    if 0 <= index < len(config["menu_items"]):
        removed_item = config["menu_items"].pop(index)[0]
        save_config(config)
        print(f"{removed_item} removed from the menu, and saved config.")
    else:
        print("Invalid input.")

def change_menu_item(config, index, new_item, new_command):
    index = int(index) - 1
    if 0 <= index < len(config["menu_items"]):
        config["menu_items"][index] = (new_item, new_command)
        print(f"Menu item {index+1} changed to {new_item}.")
        save_config(config)
    else:
        print("Invalid input.")

def change_items_per_line(config, new_value):
    if new_value > 0:
        config["display_items_per_line"] = new_value
        save_config(config)
    else:
        print("Invalid input. Please provide a positive integer value for the number of items per line.")

def edit_config(config):
    subprocess.run([config.get('editor', 'vi'), config_file])
    config = load_config()
    
def search_items(config, term):
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

    for index, item, _ in found_items:
        color = get_color(index)
        print(f"{color}{index:2}. {item.ljust(config['menu_item_length'])}{colors[0]}")

def run_command(index, item, command, config):
    print(f"You chose option {index+1}: {item}")
    if command.startswith("http"):
        browser_cmd = config["chrome_executable_path"]
        url = command
        try:
            subprocess.run([browser_cmd, url])
        except FileNotFoundError:
            print(f"Browser '{browser_cmd}' not found.")
    else:
        cmd = command.split()
        try:
            subprocess.run(cmd)
        except FileNotFoundError:
            print(f"Command '{cmd}' not found.")

        except KeyboardInterrupt:
            handle_keyboard_interrupt()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('search', nargs='?', help='search for a menu item or provide item number')
    parser.add_argument('-a', '--add', nargs=2, metavar=('ITEM', 'COMMAND'), help='add a new menu item')
    parser.add_argument('-r', '--remove', type=int, metavar='INDEX', help='remove a menu item')
    parser.add_argument('-c', '--change', nargs=3, metavar=('INDEX', 'ITEM', 'COMMAND'), help='change a menu item')
    parser.add_argument('-n', '--newline', type=int, metavar='VALUE', help='change number of items per line')
    parser.add_argument('-e', '--edit', action='store_true', help='open the configuration file in an editor')

    args = parser.parse_args()
    config = load_config()
    if config is None:
        sys.exit()

    if args.search:
        if args.search.isdigit():
            search_items(config, args.search)  # Search by item number
        else:
            search_items(config, args.search)  # Search by term
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
