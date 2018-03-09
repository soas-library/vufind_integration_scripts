#! /bin/sh
# @name: selfservice.sh
# @version: 1.0
# @creation_date: 2018-03-01
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author Simon Barron <sb174@soas.ac.uk>
#
# @purpose:
# This script edits /usr/local/vufind/local/config/vufind/config.ini to turn self-service actions in VuFind on or off
#
# Run with parameters 'on' or 'off' to turn self-service functions either on or off.

# Source function library.
. /etc/init.d/functions

config_location="/usr/local/vufind/local/config/vufind/config.ini"

on() {
    sed -i 's/hideLogin = .*/hideLogin = false/' $config_location
}

off() {
    sed -i 's/hideLogin = .*/hideLogin = true/' $config_location
}

case "$1" in
    on)
       on
       ;;
    off)
       off
       ;;
    *)
       echo "Usage: $0 {on|off}"
esac

exit 0