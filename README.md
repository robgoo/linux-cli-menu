# linux-cli-menu
Handy colorfull customizeble linux menu (python) from which webpages or linux programs can be started

with s it will show the menu (it uses a seperate config.json file with the menu items and config)


# Custom Command Menu Script

This Python script, `s`, provides a command-line interface for managing and executing a customizable menu of commands. It's designed to simplify the execution of frequently used commands or opening URLs directly from the terminal.

## Features

- **Add, Remove, and Modify Menu Items**: Easily manage your command menu with options to add, remove, or change items.
- **Search Functionality**: Quickly find menu items by name or number.
- **Customizable Display**: Set the number of items per line for the menu display.
- **Direct Configuration Editing**: Open and edit the configuration file in a text editor for advanced customization.
- **Command Execution and URL Opening**: Execute shell commands or open URLs directly from the menu.

## Installation

Ensure the script `s` is placed in a directory that's in your system's PATH and has execution permissions set:

```bash
chmod +x /path/to/s

start a menu item:

s # will show all menuitems
s goog # will start the google menu item

see below options to add / delete / edit menu items:

s -h
usage: s [-h] [-a ITEM COMMAND] [-r INDEX] [-c INDEX ITEM COMMAND] [-n VALUE] [-e] [search]

positional arguments:
  search                search for a menu item or provide item number

optional arguments:
  -h, --help            show this help message and exit
  -a ITEM COMMAND, --add ITEM COMMAND
                        add a new menu item
  -r INDEX, --remove INDEX
                        remove a menu item
  -c INDEX ITEM COMMAND, --change INDEX ITEM COMMAND
                        change a menu item
  -n VALUE, --newline VALUE
                        change number of items per line
  -e, --edit            open the configuration file in an editor


## adding new item:
s -a nos "https://www.nos.nl"

## removing an item:
s -r 3

## changing a menu item:
s -c 2 "New Item Name" "New Command or URL"

## searchinbg menu item:
s "search term"

## Changing the Number of Items Per Line
s -n 5

## Editing the Configuration File
s -e

These examples provide a quick reference for the most common tasks you can

