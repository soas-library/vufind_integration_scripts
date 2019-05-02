#! /bin/sh
# @name: vufind_maintenance.sh
# @version: 1.0
# @creation_date: 2019-05-02
# @license: GNU General Public License version 3 (GPLv3) <https://www.gnu.org/licenses/gpl-3.0.en.html>
# @author Simon Bowie <sb174@soas.ac.uk>
#
# @purpose:
# This script edits /usr/local/vufind/local/config/vufind/config.ini to turn VuFind into maintenance mode
#
# Run with parameters 'on' or 'off' to turn maintenance mode either on or off.

# Source function library.
. /etc/init.d/functions

config_location="/usr/local/vufind/local/config/vufind/config.ini"

on() {
    sed -i 's/available = .*/available = false/' $config_location
}

off() {
    sed -i 's/available = .*/available = true/' $config_location
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