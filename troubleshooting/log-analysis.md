1️. What is Log Analysis 

Log analysis helps identify system, service,
and application issues using system logs.

2️. Log Locations

Command:

ls -lh /var/log/

/var/log/messages
/var/log/secure
/var/log/syslog
/var/log/dmesg


3️. journalctl Commands (It helps troubleshoot service failures, boot problems, and system errors.)

journalctl
journalctl -xe
journalctl -u nginx
journalctl -f
journalctl -b
journalctl --since "1 hour ago"

4️. Traditional Log Monitoring
tail -f /var/log/messages
grep -i error /var/log/messages
less /var/log/secure

5️. Troubleshooting Workflow 

1. systemctl status service
2. journalctl -xe
3. journalctl -u service
4. tail -f /var/log/messages
5. 

6️. Real Admin Scenario

Example:

Service failed to start. Using systemctl status and journalctl -xe, I identified permission error in configuration file and fixed ownership, restoring service successfully.
