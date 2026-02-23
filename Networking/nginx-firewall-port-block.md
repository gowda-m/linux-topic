# Nginx Website Not Accessible – Firewall & SELinux Blocking Port

## Problem
Nginx website running on port 8080 was not accessible from browser using server IP.

---

## Investigation Steps

### 1. Verify Service Status

systemctl status nginx

### 2. Verify Listening Port

ss -tulnp
![running_image](Images/running_image.png)


![running_image](Images/running_image.png)


---

### 3. Test Local Connectivity

curl localhost:8080


Result:
Website accessible locally.

Conclusion:
Application working correctly.

---

### 4. Check Firewall Rules

firewall-cmd --list-ports

![running_image](Images/running_image)

**Observation:**
Port 8080/tcp not allowed.

---

## Root Cause
External traffic blocked by firewalld because port 8080 was not allowed.

---

## Resolution

### Allow Port in Firewall

firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload


---

### 5. Check SELinux Status bcz sometimes firewall is OK but SELinux blocks access

getenforce


Output:

Enforcing


SELinux may block services running on non-standard ports.



### (If Required) Allow Port in SELinux
Check allowed HTTP ports:

semanage port -l | grep http


Add port if missing:

semanage port -a -t http_port_t -p tcp 8080


---

## Verification

Check firewall:

firewall-cmd --list-ports


Test connectivity:

curl http://SERVER_IP:8080


Result:
Website accessible externally.

---

## Troubleshooting Flow Used

1. systemctl status nginx
2. ss -tulnp
3. curl localhost
4. firewall-cmd --list-ports
5. getenforce
6. journalctl -u nginx

---

## Prevention
Always configure firewall and SELinux policies when deploying services on custom ports.
