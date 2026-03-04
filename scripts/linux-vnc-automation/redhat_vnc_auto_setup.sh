#!/bin/bash

# ======================================================
# Script Name  : rhel_vnc_auto_setup.sh
# Description  : Automated TigerVNC + GNOME setup on RHEL
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

read -rsp "Enter password for $VNC_USER: " VNC_PASSWORD
echo ""

if [[ -z "$VNC_PASSWORD" ]]; then
   echo "❌ Password cannot be empty."
   exit 1
fi

# -----------------------------
# Install Required Packages
# -----------------------------
echo "=== [1] Installing required VNC packages ==="
dnf install -y tigervnc-server gnome-session gdm

# -----------------------------
# Create User
# -----------------------------
echo "=== [2] Creating user if not exists ==="
if id "$VNC_USER" &>/dev/null; then
    echo "✔ User $VNC_USER already exists."
else
    useradd -m "$VNC_USER"
    echo "$VNC_USER:$VNC_PASSWORD" | chpasswd
    echo "✔ User $VNC_USER created successfully."
fi

# -----------------------------
# Configure VNC Password
# -----------------------------
echo "=== [3] Setting VNC password ==="
runuser -l "$VNC_USER" -c "
mkdir -p ~/.vnc &&
echo '$VNC_PASSWORD' | vncpasswd -f > ~/.vnc/passwd &&
chmod 600 ~/.vnc/passwd
"

# -----------------------------
# Create xstartup for GNOME
# -----------------------------
echo "=== [4] Creating xstartup file ==="
runuser -l "$VNC_USER" -c "
cat > ~/.vnc/xstartup <<EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec gnome-session &
EOF
chmod +x ~/.vnc/xstartup
"

# -----------------------------
# Configure VNC Display Mapping
# -----------------------------
echo "=== [5] Creating VNC user mapping ==="
mkdir -p /etc/tigervnc
echo ":1=$VNC_USER" > /etc/tigervnc/vncserver.users
chmod 644 /etc/tigervnc/vncserver.users

# -----------------------------
# Enable Graphical Mode
# -----------------------------
echo "=== [6] Enabling graphical target ==="
systemctl set-default graphical.target

# -----------------------------
# Enable and Start VNC Service
# -----------------------------
echo "=== [7] Enabling and starting VNC service ==="
systemctl daemon-reload
systemctl enable vncserver@:1.service
systemctl restart vncserver@:1.service

# -----------------------------
# Final Output
# -----------------------------
echo ""
echo "============================================="
echo "✅ VNC setup completed successfully on RHEL."
echo "User        : $VNC_USER"
echo "Display     : :1"
echo "Port        : 5901"
echo "============================================="
