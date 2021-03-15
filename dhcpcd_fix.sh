#!/bin/bash
set -e
FILE=/etc/systemd/system/dhcpcd.service.d/restart.conf
if [[ -f "$FILE" ]]; then

    echo "No updated needed."

else

sudo mkdir -p /etc/systemd/system/dhcpcd.service.d
sudo tee /etc/systemd/system/dhcpcd.service.d/restart.conf <<"EOF"
[Service]
Restart=always
RestartSec=5s
StartLimitInterval=1
StartLimitBurst=100
EOF
sudo systemctl daemon-reload
sudo systemctl restart dhcpcd

fi
