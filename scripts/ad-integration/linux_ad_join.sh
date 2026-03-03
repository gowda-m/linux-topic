#!/bin/bash
set -euo pipefail

# ==========================================================
# Script Name : linux_ad_join.sh
# Purpose     : Join Linux server to Active Directory Domain
# Supports    : RHEL / AlmaLinux / Rocky / Ubuntu / SLES
#
# Usage:
#   sudo bash linux_ad_join.sh
#
# Notes:
#   - Prompts for credentials securely
#   - Installs required packages
#   - Configures Kerberos and SSSD
#   - Enables AD user authentication
# ==========================================================

echo "======================================="
echo " Linux Active Directory Join Script"
echo "======================================="

# -------------------------------
# Collect Domain Information
# -------------------------------

read -rp "Enter AD Domain (example.com): " AD_DOMAIN
read -rp "Enter AD Username: " AD_USER
read -srp "Enter AD Password: " AD_PASSWORD
echo ""

REALM_UPPER=$(echo "$AD_DOMAIN" | tr 'a-z' 'A-Z')
REALM_LOWER=$(echo "$AD_DOMAIN" | tr 'A-Z' 'a-z')

# -------------------------------
# Detect Package Manager
# -------------------------------

if command -v zypper >/dev/null 2>&1; then
    PKG_MANAGER="zypper"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt"
else
    echo "Unsupported Linux distribution."
    exit 1
fi

echo "Installing required packages..."

case $PKG_MANAGER in
    zypper)
        zypper install -y \
            sssd sssd-tools sssd-ad sssd-ldap sssd-krb5 \
            adcli realmd samba-client krb5-client chrony \
            oddjob oddjob-mkhomedir
        ;;
    yum|dnf)
        $PKG_MANAGER install -y \
            sssd sssd-tools sssd-ad \
            adcli realmd samba samba-common-tools \
            krb5-workstation chrony \
            oddjob oddjob-mkhomedir
        ;;
    apt)
        apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            sssd sssd-tools sssd-ad \
            adcli realmd samba-common-bin \
            krb5-user chrony \
            oddjob oddjob-mkhomedir
        ;;
esac

# -------------------------------
# Configure Time Sync (Chrony)
# -------------------------------

echo "Configuring time synchronization..."

if [ -f /etc/chrony.conf ]; then
    cat > /etc/chrony.conf <<EOF
server ${REALM_LOWER} iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
    systemctl enable chronyd || true
    systemctl restart chronyd || true
fi

# -------------------------------
# Configure Kerberos
# -------------------------------

echo "Configuring Kerberos..."

cat > /etc/krb5.conf <<EOF
[libdefaults]
default_realm = ${REALM_UPPER}
dns_lookup_realm = true
dns_lookup_kdc = true
rdns = false
ticket_lifetime = 24h
forwardable = yes

[domain_realm]
.${REALM_LOWER} = ${REALM_UPPER}
${REALM_LOWER} = ${REALM_UPPER}
EOF

# -------------------------------
# Join Active Directory
# -------------------------------

echo "Joining domain..."

if echo "$AD_PASSWORD" | realm join --user="$AD_USER" "$AD_DOMAIN" --verbose; then
    echo "Domain join successful."
else
    echo "Domain join failed or system already joined."
fi

# -------------------------------
# Configure SSSD
# -------------------------------

echo "Configuring SSSD..."

cat > /etc/sssd/sssd.conf <<EOF
[sssd]
domains = ${AD_DOMAIN}
config_file_version = 2
services = nss, pam

[domain/${AD_DOMAIN}]
id_provider = ad
auth_provider = ad
access_provider = ad

override_homedir = /home/%u
default_shell = /bin/bash

cache_credentials = True
enumerate = false
ldap_id_mapping = true
EOF

chmod 600 /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf

systemctl enable sssd
systemctl restart sssd

echo ""
echo "======================================="
echo " Domain join process completed."
echo "======================================="
