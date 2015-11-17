#!/bin/bash
if [[ ! `/opt/observium/discovery.php -h $1 | grep "does not exist"` ]]; then
	echo "1"
fi

