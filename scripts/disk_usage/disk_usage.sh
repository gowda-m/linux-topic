
---

## 🧾 Script

```bash
#!/bin/bash

# Disk usage threshold
THRESHOLD=80

# Get disk usage percentage
USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Current Disk Usage: $USAGE%"

# Check threshold
if [ "$USAGE" -gt "$THRESHOLD" ]
then
    echo "WARNING: Disk usage is above $THRESHOLD%"
else
    echo "Disk usage is under control"
fi
