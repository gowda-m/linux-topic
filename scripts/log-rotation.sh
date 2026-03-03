#!/bin/bash

###############################################################
# Log Rotation & Archive Cleanup Script
###############################################################

set -euo pipefail

# ==============================
# Configuration
# ==============================

APP_BASE="${APP_BASE:-/opt/app/domain/servers}"
ARCHIVE_BASE="${ARCHIVE_BASE:-/mnt/archive_storage/logs}"

SERVERS=("APP1" "APP2" "APP3" "APP4")

LOCAL_KEEP_DATES=5
ARCHIVE_KEEP_DATES=15

DATE_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'

echo "===================================="
echo "Starting Log Rotation Process"
echo "===================================="

###############################################
# 1️⃣ LOCAL ROTATION
###############################################

echo ""
echo "Running LOCAL Log Rotation..."

for SERVER in "${SERVERS[@]}"; do
    LOG_DIR="$APP_BASE/$SERVER/log"
    ARCHIVE_DIR="$ARCHIVE_BASE/$SERVER"

    [ -d "$LOG_DIR" ] || continue

    mkdir -p "$ARCHIVE_DIR"

    echo "Processing SERVER: $SERVER"

    mapfile -t LOG_DATES < <(
        ls -1 "$LOG_DIR"/server.log.* 2>/dev/null \
        | awk -F'.' '{print $NF}' \
        | grep -E "$DATE_REGEX" \
        | sort -u
    )

    [ ${#LOG_DATES[@]} -eq 0 ] && continue

    mapfile -t KEEP_LIST < <(
        printf "%s\n" "${LOG_DATES[@]}" | tail -n "$LOCAL_KEEP_DATES"
    )

    echo "Keeping LOCAL dates: ${KEEP_LIST[*]}"

    for file in "$LOG_DIR"/server.log.*; do
        file_date=$(awk -F'.' '{print $NF}' <<< "$file")

        [[ ! "$file_date" =~ $DATE_REGEX ]] && continue

        if [[ ! " ${KEEP_LIST[*]} " =~ " $file_date " ]]; then
            echo "Moving → $file"
            mv "$file" "$ARCHIVE_DIR"/
            gzip -f "$ARCHIVE_DIR/$(basename "$file")"
        fi
    done
done

###############################################
# 2️⃣ ARCHIVE CLEANUP
###############################################

echo ""
echo "Running ARCHIVE Cleanup..."

for SERVER in "${SERVERS[@]}"; do
    ARCHIVE_DIR="$ARCHIVE_BASE/$SERVER"
    [ -d "$ARCHIVE_DIR" ] || continue

    echo "Cleaning ARCHIVE for: $SERVER"

    mapfile -t ALL_DATES < <(
        ls -1 "$ARCHIVE_DIR"/server.log.*.gz 2>/dev/null \
        | awk -F'.' '{print $(NF-1)}' \
        | grep -E "$DATE_REGEX" \
        | sort -u
    )

    [ ${#ALL_DATES[@]} -eq 0 ] && continue

    mapfile -t KEEP_LIST < <(
        printf "%s\n" "${ALL_DATES[@]}" | tail -n "$ARCHIVE_KEEP_DATES"
    )

    echo "Keeping ARCHIVE dates: ${KEEP_LIST[*]}"

    for file in "$ARCHIVE_DIR"/server.log.*.gz; do
        file_date=$(awk -F'.' '{print $(NF-1)}' <<< "$file")

        if [[ ! " ${KEEP_LIST[*]} " =~ " $file_date " ]]; then
            echo "Deleting → $file"
            rm -f "$file"
        fi
    done
done

echo ""
echo "Log Rotation Completed Successfully."
exit 0
