#!/bin/bash
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo '########################################'
echo 'FULL LOG ........'
echo 'located at /tmp/adsbx_update_log .......'
echo '########################################'
echo '..'
echo 'cloning to decoder /tmp .......'
cd /tmp
git clone --quiet --depth 1 https://github.com/adsbxchange/readsb.git > /tmp/adsbx_update_log

echo 'compiling readsb (this can take a while) .......'
cd readsb
#make -j3 AIRCRAFT_HASH_BITS=12 RTLSDR=yes
make -j3 AIRCRAFT_HASH_BITS=12 RTLSDR=yes OPTIMIZE="-mcpu=arm1176jzf-s -mfpu=vfp"  >> /tmp/adsbx_update_log

echo 'stop services .......'
systemctl stop readsb.service
systemctl stop adsbexchange-feed.service
systemctl stop adsbexchange-978.service
systemctl stop adsbexchange-stats.service

echo 'updating adsbx stats .......'
wget --quiet -O /tmp/axstats.sh https://raw.githubusercontent.com/adsbxchange/adsbexchange-stats/master/stats.sh >> /tmp/adsbx_update_log
(sudo bash /tmp/axstats.sh) 2>&1 >> /tmp/adsbx_update_log

echo 'cleaming up stats /tmp .......'
rm -f /tmp/axstats.sh
rm -f -R /tmp/adsbexchange-stats-git

echo 'removing old binaries .......'
rm  -f /usr/bin/adsbxfeeder
echo 'removing readsb binaries .......'
rm  -f /usr/bin/adsbx-feeder
rm  -f /usr/bin/adsbx-978
rm  -f /usr/bin/readsb

echo 'copying new readsb binaries .......'
cp readsb /usr/bin/adsbxfeeder
cp readsb /usr/bin/adsbx-978
cp readsb /usr/bin/readsb

echo 'starting services .......'
systemctl start readsb.service
systemctl start adsbexchange-feed.service
systemctl start adsbexchange-978.service
systemctl start adsbexchange-stats.service

echo 'cleaning up decoder .......'
cd /tmp
rm -f -R /tmp/readsb

echo 'cloning to python virtual environment for mlat-client .......'
apt install -y python3-venv >> /tmp/adsbx_update_log
/usr/bin/python3 -m venv /usr/local/share/adsbexchange/venv/

echo 'stopping mlat services .......'
systemctl stop adsbexchange-mlat.service

echo 'cloning to mlat-client /tmp .......'
cd /tmp
git clone --quiet --depth 1 --single-branch https://github.com/adsbxchange/mlat-client.git >> /tmp/adsbx_update_log

echo 'building and installing mlat-client to virtual-environment .......'
cd mlat-client
source /usr/local/share/adsbexchange/venv/bin/activate >> /tmp/adsbx_update_log
python3 setup.py build >> /tmp/adsbx_update_log
python3 setup.py install >> /tmp/adsbx_update_log

echo 'starting services .......'
systemctl start adsbexchange-mlat.service

echo 'cleaning up mlat-client .......'
cd /tmp
rm -f -R /tmp/mlat-client
sudo rm /usr/local/share/adsbexchange/venv/bin/fa-mlat-client

echo 'update uat ...'
echo 'stop services .......'
sudo systemctl stop adsbexchange-978-convert.service

cd /tmp
git clone https://github.com/adsbxchange/uat2esnt.git >> /tmp/adsbx_update_log
cd uat2esnt
make  >> /tmp/adsbx_update_log
cp uat2esnt /usr/local/share/uat2esnt
cd /tmp
rm -f -R /tmp/uat2esnt

echo 'start uat services .......'
sudo systemctl start adsbexchange-978-convert.service

echo "#####################################"
cat /boot/adsbx-uuid
echo "#####################################"
sed -e 's$^$https://www.adsbexchange.com/api/feeders/?feed=$' /boot/adsbx-uuid
echo "#####################################"

echo '--------------------------------------------'
echo '--------------------------------------------'
echo '             UPDATE COMPLETE'
echo '      FULL LOG:  /tmp/adsbx_update_log'
echo '--------------------------------------------'
echo '--------------------------------------------'
exit 0
