#!/bin/bash

# Function to answer "yes" to prompts
function yes_or_continue() {
    while true; do
        read -p "$1 (yes/no): " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Add repository and architecture
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
sudo dpkg --add-architecture i386

# Install packages
sudo apt-get update
sudo apt-get install -y glances vlc* htop openjdk-11-jre openjdk-11-jre-headless hardinfo gparted* gpart kpartx btrfs-progs e2fsprogs f2fs-tools dosfstools hfsutils hfsprogs jfsutils xfsprogs util-linux lvm2 dmsetup ni>

# Install network manager packages
sudo apt install -y network-manager-config-connectivity-ubuntu network-manager-dev network-manager-gnome network-manager-openvpn network-manager-openvpn-gnome network-manager-pptp network-manager-pptp-gnome budgie-netw>

# Install graphics-related packages
sudo apt-get install -y freeglut3-dev binutils-gold g++ mesa-common-dev build-essential libglm-dev mesa-utils vulkan-tools libglu1-mesa-dev libdrm-amdgpu1 libdrm-common libdrm-dev libdrm-intel1 libdrm-nouveau2 libdrm-r>

# Download AACS keys for VLC
sudo apt install libaacs0 libbluray-bdj libbluray2 -y
sudo mkdir -p ~/.config/aacs/
cd ~/.config/aacs/ && wget http://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg

# Install Flatpak and add Flathub
sudo apt install flatpak gnome-software gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Run sensors-detect and start kmod service
yes_or_continue "Run sensors-detect (answer 'yes' to all prompts)"
sudo sensors-detect
sudo /etc/init.d/kmod start

# Install ClamAV and update signatures
sudo apt-get install clamav* -y
sudo systemctl stop clamav-freshclam && sudo freshclam
sudo systemctl start clamav-freshclam

# Install Linux tools and set CPU performance
sudo apt-get install linux-tools-common linux-tools-generic linux-tools-$(uname -r) -y
sudo cpupower -c all frequency-set -g performance

# Create cpupower.service
cat << EOF | sudo tee /etc/systemd/system/cpupower.service
[Unit]
Description=CPU performance
[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower -c all frequency-set -g performance
[Install]
WantedBy=multi-user.target
EOF

# Enable and start cpupower.service
sudo systemctl daemon-reload
sudo systemctl enable cpupower.service
sudo systemctl restart cpupower.service

# Configure GRUB
sudo nano /etc/default/grub
# Make necessary changes in the GRUB configuration

# Add your GRUB configuration changes below
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash lockdown=confidentiality"' | sudo tee -a /etc/default/grub
echo 'GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 console=ttyS0,38400n8 elevator=noop zswap.enabled=0 zswap.compressor=lz4 zswap.max_pool_percent=50"' | sudo tee -a /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=true' | sudo tee -a /etc/default/grub
echo 'GRUB_PRELOAD_MODULES="part_gpt part_msdos"' | sudo tee -a /etc/default/grub

# Update GRUB
sudo update-grub

# Configure modules for LZ4 compression
echo "lz4" | sudo tee -a /etc/modules
echo "lz4_compress" | sudo tee -a /etc/modules

# Update initramfs
sudo update-initramfs -u

# Configure systemd timesyncd
sudo nano /etc/systemd/timesyncd.conf
# Make necessary changes in the timesyncd configuration

# Restart timesyncd
sudo systemctl restart systemd-timesyncd

echo "Script completed successfully.
