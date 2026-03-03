# log-rotation

Lightweight Bash-based log lifecycle management for application servers.

---

## Problem

Application logs grow continuously.  
Uncontrolled growth leads to:

- Disk exhaustion  
- Service interruption  
- Performance degradation  

This script enforces deterministic log retention without relying on system logrotate.

---

## Example Structure

```
/opt/app/domain/servers/APP1/log/server.log.2026-03-01
/mnt/archive_storage/logs/APP1/server.log.2026-02-10.gz
```

---

## Configuration

All configuration is defined within the script and can be overridden using environment variables.

```bash
APP_BASE="/opt/app/domain/servers"
ARCHIVE_BASE="/mnt/archive_storage/logs"

SERVERS=("APP1" "APP2" "APP3" "APP4")

LOCAL_KEEP_DATES=5
ARCHIVE_KEEP_DATES=15
```

---

### Configuration Parameters

| Parameter          | Description                                       |
|--------------------|---------------------------------------------------|
| APP_BASE           | Base directory containing application log folders |
| ARCHIVE_BASE       | Archive storage path                              |
| SERVERS            | List of server instances                          |
| LOCAL_KEEP_DATES   | Number of recent log dates retained locally       |
| ARCHIVE_KEEP_DATES | Number of archive log dates retained              |

---

## Scheduling (Cron Example)

Execute daily at 02:00 AM:

```bash
0 2 * * * /bin/bash /path/to/log_rotation.sh >> /var/log/log_rotation.log 2>&1
```

---

## Requirements

- Bash 4+
- gzip installed
- Proper read/write permissions
- Mounted archive storage

---

## Summary

Production-oriented log lifecycle automation with configurable retention and multi-instance support.
