#!/bin/bash
# setup_dns_auto.sh
# Этот скрипт автоматически находит имя активного подключения для интерфейса ens33
# и настраивает его на использование DNS-серверов 8.8.8.8 и 1.1.1.1, отключая авто-DNS.

set -e

# Находим имя активного подключения, связанного с ens33.
# Используем nmcli с выводом NAME и DEVICE, разделённых двоеточием.
CON_NAME=$(nmcli -g NAME,DEVICE con show --active | grep ":ens33" | cut -d: -f1 | head -n 1)

if [ -z "$CON_NAME" ]; then
    echo "Не удалось найти активное подключение для интерфейса ens33."
    exit 1
fi

echo "Найдено подключение: '$CON_NAME' для интерфейса ens33."

echo "Отключаю автоматический DNS (DHCP)..."
nmcli con mod "$CON_NAME" ipv4.ignore-auto-dns yes

echo "Устанавливаю DNS-сервера: 8.8.8.8 и 1.1.1.1..."
nmcli con mod "$CON_NAME" ipv4.dns "8.8.8.8 1.1.1.1"

echo "Перезапускаю подключение '$CON_NAME'..."
nmcli con down "$CON_NAME"
nmcli con up "$CON_NAME"

echo "Ожидаю 5 секунд для стабилизации..."
sleep 5

echo "Текущая конфигурация DNS (resolvectl status):"
resolvectl status

echo "Настройка DNS завершена успешно."
__________
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
