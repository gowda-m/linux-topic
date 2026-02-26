**Nginx service is running successfully, but website is not accessible from browser. (Firewall Port Blocked)**

http://server-ip:8080

Browser shows:  Site can't be reached

![website_not_access](Images/website_not_access.png)


**Step 1 — Verify Nginx Service**

systemctl status nginx


**Step 2 — Check Listening Port**

ss -tulnp | grep nginx

Example output:

![service_running](Images/service_running.png)


**👉 Confirms nginx is working locally.**

**Step 3 — Test Locally**

curl localhost:8080

If response comes → nginx OK.


**Step 4 — Check Firewall (Root Cause)**

firewall-cmd --list-ports

**Port 8080/tcp not listed → blocked by firewalld.**

![firewalld_check](Images/firewalld_check.png)

**Step 5 — Allow Port in Firewall**

firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

Verify:

firewall-cmd --list-ports

Output:

8080/tcp

**Step 6 — Test Again from Browser**

Open:

http://server-ip:8080

Website loads successfully.

![website_access.png](Images/website_access.png)


**Step 7 — SELinux Check (If Still Not Working)**

Check mode:

getenforce

If using custom port:

semanage port -a -t http_port_t -p tcp 8080

