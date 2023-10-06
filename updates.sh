#!/bin/bash

# Check if the script is run as root or with sudo
if [[ $EUID -ne 0 ]]; then
    # If not running as root, execute the script with sudo
    sudo bash "$0" "$@"
    exit $?
fi

# Run the commands
sudo nala upgrade -y
pihole -up && pihole -g
docker system prune -f
sudo rm /home/pihole/searxng/settings.yml.new
sudo rm /home/pihole/searxng/uwsgi.ini.new
sudo fwupdmgr get-updates
sudo apt-get install linux-tools-common linux-tools-generic linux-tools-$(uname -r) -y
sudo cpupower -c all frequency-set -g performance
sudo service systemd-timesyncd restart
sudo systemctl restart cloudflared
pihole restartdns

echo "All commands have been executed."
