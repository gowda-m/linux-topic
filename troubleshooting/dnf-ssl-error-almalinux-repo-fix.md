DNF SSL Connection Reset – AlmaLinux 9 Repository Fix

Issue

While installing packages using dnf, repositories failed with SSL errors:

![yum-error](Images/yum-error.png)

Curl error (35): SSL connect error
Connection reset by peer in connection to repo.almalinux.org:443

Commands affected:

dnf install nginx
dnf update
dnf makecache
Symptoms

Internet connectivity working

DNS resolution working

HTTPS working for other sites

**AlmaLinux repositories unreachable**


Verification
ping 8.8.8.8        ✅ OK
curl https://google.com   ✅ OK
dnf makecache       ❌ FAILED

Error:

**Cannot download repomd.xml
SSL_connect: Connection reset by peer
Root Cause**

System could not complete TLS handshake with AlmaLinux CDN mirrors.

Possible reasons:

Network firewall inspection

CDN TLS incompatibility

IPv6/CDN routing issues

Corporate or VM network filtering

DNF mirrorlist used HTTPS CDN endpoints which reset connections.

Solution (Working Fix)

Bypass CDN mirrorlist and use direct HTTP mirrors.

1. Remove existing repo files

![working-update](Images/working-update.png)

rm -f /etc/yum.repos.d/almalinux*.repo

2. Configure BaseOS Repository

   
vi /etc/yum.repos.d/baseos.repo
[baseos]
name=AlmaLinux 9 - BaseOS
baseurl=http://mirror.alwyzon.net/almalinux/9/BaseOS/x86_64/os/
enabled=1
gpgcheck=0
4. Configure AppStream Repository
vi /etc/yum.repos.d/appstream.repo
[appstream]
name=AlmaLinux 9 - AppStream
baseurl=http://mirror.alwyzon.net/almalinux/9/AppStream/x86_64/os/
enabled=1
gpgcheck=0
5. Configure Extras Repository
vi /etc/yum.repos.d/extras.repo
[extras]
name=AlmaLinux 9 - Extras
baseurl=http://mirror.alwyzon.net/almalinux/9/extras/x86_64/os/
enabled=1
gpgcheck=0
6. Rebuild Cache
dnf clean all
rm -rf /var/cache/dnf/*
dnf makecache

Expected output:

Metadata cache created.
6. Install Package
dnf install nginx -y

✅ Installation successful.
