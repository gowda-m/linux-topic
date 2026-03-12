#!/bin/bash

# Service name to monitor
SERVICE="sshd"

echo "Checking status of $SERVICE service..."

# Check if service is running
if systemctl is-active --quiet $SERVICE
then
    echo "$SERVICE service is running"
else
    echo "$SERVICE service is not running"
    echo "Starting $SERVICE service..."
    systemctl start $SERVICE
    echo "$SERVICE service started successfully"
fi
