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

# Remove all snap packages
snap_list=$(snap list --all | awk '{if (NR>1) print $1}')
for snap in $snap_list; do
    yes_or_continue "Remove $snap (snap package)"
    sudo snap remove $snap
done

# Add repository and architecture
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
sudo dpkg --add-architecture i386

# Install packages
sudo apt-get update
sudo apt-get install -y glances vlc* htop openjdk-11-jre openjdk-11-jre-headless hardinfo gparted* gpart kpartx btrfs-progs e2fsprogs f2fs-tools dosfstools hfsutils hfsprogs jfsutils xfsprogs util-linux lvm2 dmsetup nilfs-tools ntfs-3g fancontrol floppyd attr quota reiser4progs reiserfsprogs udftools libdvd-pkg lm-sensors i2c-tools gnu-standards duperemove dh-make mtools udfclient vlc-plugin-fluidsynth vlc-plugin-jack vlc-plugin-svg xfsdump dvd+rw-tools gnome-tweaks build-essential software-properties-common libcanberra-gtk-module libcanberra-gtk3-module apparmor-utils wireguard network-manager-openvpn mokutil fonts* remmina* libaacs0 libbluray-bdj libbluray2 -y

# Install network manager packages
sudo apt install -y network-manager-config-connectivity-ubuntu network-manager-dev network-manager-gnome network-manager-openvpn network-manager-openvpn-gnome network-manager-pptp network-manager-pptp-gnome budgie-network-manager-applet network-manager-config-connectivity-debian network-manager-fortisslvpn network-manager-fortisslvpn-gnome network-manager-iodine network-manager-iodine-gnome network-manager-l2tp network-manager-l2tp-gnome network-manager-openconnect network-manager-openconnect-gnome network-manager-ssh network-manager-ssh-gnome network-manager-strongswan network-manager-vpnc network-manager-vpnc-gnome strongswan-nm -y

# Install graphics-related packages
sudo apt-get install -y freeglut3-dev binutils-gold g++ mesa-common-dev build-essential libglm-dev mesa-utils vulkan-tools libglu1-mesa-dev libdrm-amdgpu1 libdrm-common libdrm-dev libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libdrm2 libegl-mesa0 libgbm1 libgl1-mesa-dri libglapi-mesa libglx-mesa0 libxatracker2 mesa-common-dev mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mesa* -y

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

# Remove and disable Snap
sudo apt remove --autoremove snapd
sudo rm -rf /var/cache/snapd/
sudo rm -fr ~/snap
sudo apt-mark hold snapd
sudo apt remove plasma-discover-backend-snapd

# Create and configure nosnap.pref
cat << EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

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