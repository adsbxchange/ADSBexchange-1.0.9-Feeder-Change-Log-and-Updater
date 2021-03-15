#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

FILE=/etc/systemd/system/dhcpcd.service.d/restart.conf
if [[ -f "$FILE" ]]; then

    echo "No updated needed."

else

mkdir -p /etc/systemd/system/dhcpcd.service.d
tee /etc/systemd/system/dhcpcd.service.d/restart.conf <<"EOF"
[Service]
Restart=always
RestartSec=5s
StartLimitInterval=1
StartLimitBurst=100
EOF
systemctl daemon-reload
systemctl restart dhcpcd

fi
