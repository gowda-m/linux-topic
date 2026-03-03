# Linux Active Directory Integration Script

Automated Bash script to join Linux systems to an Active Directory domain.

---

## Overview

This script automates Linux to Active Directory integration using:

- realmd
- adcli
- Kerberos
- SSSD

It installs required packages, configures authentication services, and enables AD user logins.

---

## Supported Distributions

- RHEL / AlmaLinux / Rocky Linux
- Ubuntu / Debian
- SLES

---

## Script Location

```
scripts/ad-integration/linux_ad_join.sh
```

---

## How to Execute

### 1️⃣ Navigate to Script Directory

```bash
cd scripts/ad-integration
```

### 2️⃣ Make Script Executable

```bash
chmod +x linux_ad_join.sh
```

### 3️⃣ Run the Script (as root or with sudo)

```bash
sudo ./linux_ad_join.sh
```

---

## What Happens During Execution

The script will:

1. Detect the Linux distribution
2. Install required packages
3. Configure time synchronization
4. Configure Kerberos
5. Join the system to the AD domain
6. Configure SSSD
7. Enable AD authentication

You will be prompted to enter:

- Active Directory Domain
- AD Username (with domain join privileges)
- AD Password (secure input)

---

## Security Notes

- Credentials are not stored in the script.
- Password is securely prompted at runtime.
- Do not hardcode credentials in production environments.
- Review configuration before use in enterprise infrastructure.

---

## Purpose

This project demonstrates practical enterprise Linux automation for Active Directory integration using secure Bash scripting.
