#!/bin/bash

set -e

INTERFACES="ens33 eth0"

for INTERFACE in $INTERFACES; do
    CON_NAMES=$(nmcli -g NAME,DEVICE con show --active | grep ":$INTERFACE" | cut -d: -f1)
    
    if [ -z "$CON_NAMES" ]; then
        echo "No active connections: $INTERFACE."
        continue
    fi

    for CON_NAME in $CON_NAMES; do
        echo "Conn found: '$CON_NAME' in $INTERFACE."
        
        echo "Automatic DNS (DHCP) is downing..."
        nmcli con mod "$CON_NAME" ipv4.ignore-auto-dns yes
        
        echo "Possible DNS servers: 8.8.8.8 и 1.1.1.1..."
        nmcli con mod "$CON_NAME" ipv4.dns "8.8.8.8 1.1.1.1"
        
        echo "Reconnecting '$CON_NAME'..."
        nmcli con down "$CON_NAME"
        nmcli con up "$CON_NAME"
        
        echo "Configuring..."
        sleep 5
    done
done

echo "Current DNS configuration (resolvectl status):"
resolvectl status
