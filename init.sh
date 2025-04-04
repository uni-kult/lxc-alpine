#!/bin/sh
set -eu

# get dotfiles

truncate -s 0 /etc/motd
apk update && apk upgrade
wget -O /var/tmp/tempfile http://speedtest.belwue.net/random-100M >/dev/null 2>&1 && find / -size +1k >/dev/null 2>&1 && ls -R / >/dev/null 2>&1 && rm /var/tmp/tempfile >/dev/null 2>&1 && sync  # increase entropy
apk add docker docker-compose curl micro tmux htop mosh rsync ufw fail2ban
rc-update add docker default
/etc/init.d/docker start
mkdir /config/

echo "41 3 * * * apk update && apk upgrade" | tee -a /var/spool/cron/crontabs/root > /dev/null

rc-update add ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow from 172.16.81.0/24 to any port ssh
ufw allow from 172.16.81.0/24 to any port http
ufw allow from 172.16.81.0/24 to any port 60000:61000 proto udp #mosh
ufw allow from 10.200.0.0/16 to any port ssh
ufw allow from 10.200.0.0/16 to any port http
ufw allow from 10.200.0.0/16 to any port 60000:61000 proto udp #mosh
echo "y" | ufw enable
ufw reload
rc-update add fail2ban
rc-service fail2ban start
service sshd restart
