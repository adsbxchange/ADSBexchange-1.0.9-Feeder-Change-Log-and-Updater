#!/bin/bash
set -e

# Rerun script again as root if executed as normal user the first time
if [ $EUID -gt 0 ]
then
  echo "Script needs to run as root or sudo."
  exit 
fi

FILE=/etc/systemd/system/dhcpcd.service.d/restart.conf
if [[ -f "$FILE" ]]; then

    echo "Seems like file exists. No updated likely needed."

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
