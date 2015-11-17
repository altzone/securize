#!/bin/bash
if [[ `grep -r  "$1" /usr/local/nagios/etc/objects/clients/` ]]; then
head -n4 `grep -r  "$1" /usr/local/nagios/etc/objects/clients/ | grep address | sed s/:/" "/g | awk {'print $1'}` | grep host_name | awk {'print $2'}
fi
