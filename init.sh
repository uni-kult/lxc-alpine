#!/bin/sh
set -eu

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

cat <<EOF > .profile
alias ls='ls -hF'
alias la='ls -Al'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias mkdir='mkdir -v'
alias ..='cd ..'
alias x='exit'
alias du2='du -ach --max-depth=1'
alias t='tmux new -As0'
alias 1='ping one.one.one.one'

export VISUAL=micro
export EDITOR="$VISUAL"
#export MICRO_CONFIG_HOME="$HOME/.micro"

bold="\e[1m"
reset="\e[0m"
red="\e[31m"
white="\e[37m"
yellow="\e[33m"

userStyle="${USER:-root}"
userStyle="$([ "$userStyle" = "root" ] && echo "$red" || echo "$white")"
hostStyle="$([ -n "$SSH_TTY" ] || [ -n "$PROMPT_RED_HOST" ] && echo "$bold$red" || echo "$white")"

sps() {
  current_path=$(echo "$PWD" | sed "s|$HOME|~|")
  [ "$current_path" = "~" ] && echo "$current_path" || {
    path_parent="${current_path%/*}"
    path_parent_short=$(echo "$path_parent" | sed -r 's|/([^/]{2})[^/]{2,}|/\1|g')
    directory="${current_path##*/}"
    echo "$path_parent_short/$directory"
  }
}

PS1="${userStyle}\u@${hostStyle}\h${reset}:${white}\$(sps)${reset}\$ "
PS2="${yellow}→ ${reset}"
export PS1 PS2
EOF
