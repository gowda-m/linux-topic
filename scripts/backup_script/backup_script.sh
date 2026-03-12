#!/bin/bash

# Source directory to backup
SOURCE="/home"

# Backup destination directory
DEST="/backup"

# Date format
DATE=$(date +%Y-%m-%d)

# Backup file name
BACKUP_FILE="backup-$DATE.tar.gz"

echo "Starting backup..."

# Create backup
tar -czf $DEST/$BACKUP_FILE $SOURCE

echo "Backup completed successfully!"
echo "Backup file: $DEST/$BACKUP_FILE"
