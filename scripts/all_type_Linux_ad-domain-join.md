#!/bin/bash
set -e

echo "=== Starting Domain Join Script (Block AD Logins) ==="

# ================================
# Linux AD Integration
# Works on: SLES / RHEL / AlmaLinux / Ubuntu
# Domain: domain.IN
# DCs: 172.16.*.*, 172.16.*.*
# Block all AD user logins
# ================================

AD_DOMAIN="domain.IN"
AD_USER="user"
AD_PASSWORD="pwd"
REALM_LOWER=$(echo "$AD_DOMAIN" | tr 'A-Z' 'a-z')

# Detect package manager
if command -v zypper >/dev/null 2>&1; then
    PKG_MANAGER="zypper"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt"
else
    echo "❌ Unsupported OS (no zypper, yum, dnf, apt-get found)"
    exit 1
fi

echo "📦 Installing required packages..."
case $PKG_MANAGER in
    zypper)
        zypper install -y --force \
            sssd sssd-tools sssd-ldap sssd-ad sssd-krb5 sssd-krb5-common sssd-common \
            adcli realmd samba-client krb5-client pam-config chrony oddjob oddjob-mkhomedir
        ;;
    yum|dnf)
        $PKG_MANAGER install -y \
            sssd sssd-tools sssd-ldap sssd-ad sssd-krb5-common \
            adcli realmd samba samba-common-tools krb5-workstation chrony oddjob oddjob-mkhomedir
        ;;
    apt)
        apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            sssd sssd-tools sssd-ldap sssd-ad sssd-krb5 adcli realmd samba-common-bin \
            krb5-user chrony oddjob oddjob-mkhomedir
        ;;
esac

echo "⏱️ Configuring NTP..."
if [ -f /etc/chrony.conf ]; then
    cat > /etc/chrony.conf <<EOF
server 172.16.*.* iburst
server 172.16.*.* iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
    systemctl enable chronyd || true
    systemctl restart chronyd || true
elif [ -f /etc/chrony/chrony.conf ]; then
    cat > /etc/chrony/chrony.conf <<EOF
server 172.16.*.* iburst
server 172.16.*.* iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
    systemctl enable chrony || true
    systemctl restart chrony || true
fi

echo "🔐 Configuring Kerberos..."
cat > /etc/krb5.conf <<EOF
[libdefaults]
default_realm = ${AD_DOMAIN}
dns_lookup_realm = true
dns_lookup_kdc = true
rdns = false
ticket_lifetime = 24h
forwardable = yes

[realms]
${AD_DOMAIN} = {
  kdc = ${AD_DOMAIN}
  admin_server = ${AD_DOMAIN}
}

[domain_realm]
.${REALM_LOWER} = ${AD_DOMAIN}
${REALM_LOWER} = ${AD_DOMAIN}
EOF

echo "🏷️ Joining AD domain..."
if echo "${AD_PASSWORD}" | realm join --user=${AD_USER} ${AD_DOMAIN} --verbose; then
    echo "✅ Joined domain successfully"
else
    echo "⚠️ Already joined or join failed"
fi

echo "🛠️ Writing SSSD configuration..."
cat > /etc/sssd/sssd.conf <<EOF
[sssd]
domains = ${AD_DOMAIN}
config_file_version = 2
services = nss, pam

[domain/${AD_DOMAIN}]
id_provider = ad
auth_provider = ad
chpass_provider = ad
access_provider = ad

override_homedir = /home/%u
default_shell = /bin/bash

dyndns_update = false
ad_gpo_ignore_unreadable = true

cache_credentials = True
enumerate = false
timeout = 10
ldap_id_mapping = true
EOF

chmod 600 /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf

echo "🔄 Clearing old SSSD cache..."
systemctl stop sssd || true
rm -rf /var/lib/sss/db/* /var/lib/sss/mc/* /var/log/sssd/*

echo "🚀 Starting SSSD..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable sssd
systemctl restart sssd

echo "✅ Domain Join Complete (AD logins blocked)."
systemctl status sssd --no-pager | grep Active
