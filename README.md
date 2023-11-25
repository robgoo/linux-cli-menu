# linux-cli-menu
Handy colorfull customizeble linux menu (python) from which webpages or linux programs can be started

with s it will show the menu (it uses a seperate config.json file with the menu items and config)

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
