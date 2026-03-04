#!/bin/bash

# ======================================================
# Script Name  : sles_vnc_auto_setup.sh
# Description  : Automated TigerVNC + GNOME setup on SLES
# Purpose      : Creates user, configures VNC, enables GUI
# ======================================================

set -e

# -----------------------------
# Root Check
# -----------------------------
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root."
   exit 1
fi

# -----------------------------
# User Input
# -----------------------------
read -rp "Enter VNC username to create: " VNC_USER

if [[ -z "$VNC_USER" ]]; then
   echo "❌ Username cannot be empty."
   exit 1
fi

read -rsp "Enter password for $VNC_USER: " VNC_PASS
echo ""

if [[ -z "$VNC_PASS" ]]; then
   echo "❌ Password cannot be empty."
   exit 1
fi

VNC_HOME="/home/$VNC_USER"
VNC_DIR="$VNC_HOME/.vnc"

echo "=== [1] Installing required VNC packages ==="
zypper --gpg-auto-import-keys refresh
zypper -n install vncmanager vncmanager-controller xorg-x11-Xvnc gdm gnome-session

echo "=== [2] Creating user: $VNC_USER ==="
if id "$VNC_USER" &>/dev/null; then
   echo "✔ User $VNC_USER already exists."
else
   useradd -m "$VNC_USER"
   echo "$VNC_USER:$VNC_PASS" | chpasswd
   echo "✔ User $VNC_USER created successfully."
fi

echo "=== [3] Configuring VNC password ==="
rm -rf "$VNC_DIR"

runuser -l "$VNC_USER" -c "
mkdir -p ~/.vnc &&
echo '$VNC_PASS' | vncpasswd -f > ~/.vnc/passwd &&
chmod 600 ~/.vnc/passwd
"

chown -R "$VNC_USER:$VNC_USER" "$VNC_DIR"

# Kill existing session if running
vncserver -kill :1 &>/dev/null || true

echo "=== [4] Configuring VNC defaults ==="
mkdir -p /etc/tigervnc

cat <<EOF > /etc/tigervnc/vncserver-config-defaults
session=gnome
securitytypes=vncauth,tlsvnc
geometry=1920x1080
localhost
alwaysshared
EOF

echo ":1=$VNC_USER" > /etc/tigervnc/vncserver.users

echo "=== [5] Enabling graphical target ==="
systemctl set-default graphical.target

echo "=== [6] Configuring GDM ==="
sed -i 's/^DISPLAYMANAGER=.*/DISPLAYMANAGER="gdm"/' /etc/sysconfig/displaymanager 2>/dev/null || \
echo 'DISPLAYMANAGER="gdm"' >> /etc/sysconfig/displaymanager

mkdir -p /etc/gdm
cat <<EOF > /etc/gdm/custom.conf
[daemon]
WaylandEnable=false
EOF

systemctl enable display-manager
systemctl restart display-manager

echo "=== [7] Enabling VNC service ==="
systemctl enable vncmanager
systemctl restart vncmanager

echo ""
echo "============================================="
echo "✅ VNC setup completed successfully."
echo "User        : $VNC_USER"
echo "Display     : :1"
echo "Port        : 5901"
echo "============================================="
