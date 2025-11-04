#!/bin/bash
# =====================================================
# Automated Backup System
# Author: LINGAMPALLI SREEVISHNU
# Description:
#   Creates compressed backups with checksum verification,
#   automatic cleanup (daily, weekly, monthly),
#   and restore functionality.
# =====================================================
# --- Paths & Config ---
CONFIG_FILE="./backup.config"
LOG_FILE="./logs/backup.log"
LOCK_FILE="/tmp/backup.lock"
DATE_NOW=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
# --- Check for config file ---
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[$DATE_NOW] ERROR: Configuration file not found!" | tee -a "$LOG_FILE"
  exit 1
fi
# --- Load configuration ---
source "$CONFIG_FILE"
# --- Helper: Logging ---
log() {
  local LEVEL=$1
  local MSG=$2
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $LEVEL: $MSG" | tee -a "$LOG_FILE"
}
# --- Helper: Exit cleanly ---
cleanup_exit() {
  rm -f "$LOCK_FILE"
  exit $1
}
# --- Prevent multiple runs ---
if [ -f "$LOCK_FILE" ]; then
  log "ERROR" "Another backup process is already running!"
  exit 1
fi
touch "$LOCK_FILE"
# --- Read mode and arguments ---
MODE="backup"
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  SRC_DIR=$2
elif [ "$1" == "--restore" ]; then
  MODE="restore"
  BACKUP_FILE=$2
  if [ "$3" == "--to" ]; then
    RESTORE_DIR=$4
  else
    log "ERROR" "Usage: ./backup.sh --restore <backup-file> --to <destination-folder>"
    cleanup_exit 1
  fi
else
  SRC_DIR=$1
fi
# --- Validate backup destination ---
mkdir -p "$BACKUP_DESTINATION" "./logs"
# =====================================================
# Function: Create Backup
# =====================================================
create_backup() {
  local SRC="$1"
  local BACKUP_FILE="${BACKUP_DESTINATION}/backup-${TIMESTAMP}.tar.gz"
  local EXCLUDES=()
  # Validate source
  if [ ! -d "$SRC" ]; then
    log "ERROR" "Source directory not found: $SRC"
    cleanup_exit 1
  fi
  IFS=',' read -ra PATTERNS <<< "$EXCLUDE_PATTERNS"
  for pattern in "${PATTERNS[@]}"; do
    EXCLUDES+=("--exclude=${pattern}")
  done
  if [ "$DRY_RUN" = true ]; then
    log "DRY-RUN" "Would create backup of $SRC at $BACKUP_FILE"
    cleanup_exit 0
  fi
  log "INFO" "Starting backup for $SRC..."
  tar -czf "$BACKUP_FILE" "${EXCLUDES[@]}" "$SRC" 2>>"$LOG_FILE"
  if [ $? -ne 0 ]; then
    log "ERROR" "Backup creation failed!"
    cleanup_exit 1
  fi
  sha256sum "$BACKUP_FILE" > "${BACKUP_FILE}.sha256"
  if [ $? -eq 0 ]; then
    log "SUCCESS" "Backup created: $(basename $BACKUP_FILE)"
  else
    log "ERROR" "Failed to create checksum!"
  fi
  verify_backup "$BACKUP_FILE"
}
# =====================================================
# Function: Verify Backup
# =====================================================
verify_backup() {
  local FILE=$1
  log "INFO" "Verifying checksum for $(basename $FILE)..."
  sha256sum -c "${FILE}.sha256" >> "$LOG_FILE" 2>&1
  if [ $? -eq 0 ]; then
    log "SUCCESS" "Checksum verified successfully."
  else
    log "ERROR" "Checksum verification failed for $FILE!"
  fi
  # Optional test extraction
  mkdir -p ./_test_extract
  tar -tzf "$FILE" >/dev/null 2>>"$LOG_FILE"
  if [ $? -eq 0 ]; then
    log "INFO" "Archive integrity test passed."
  else
    log "ERROR" "Archive integrity test failed!"
  fi
  rm -rf ./_test_extract
}
# =====================================================
# Function: Restore Backup
# =====================================================
restore_backup() {
  local BACKUP_FILE=$1
  local DEST_DIR=$2
  if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR" "Backup file not found: $BACKUP_FILE"
    cleanup_exit 1
  fi
  mkdir -p "$DEST_DIR"
  log "INFO" "Restoring $BACKUP_FILE to $DEST_DIR..."
  tar -xzf "$BACKUP_FILE" -C "$DEST_DIR" >> "$LOG_FILE" 2>&1
  if [ $? -eq 0 ]; then
    log "SUCCESS" "Backup restored to $DEST_DIR"
  else
    log "ERROR" "Restore failed!"
  fi
}
# =====================================================
# Function: Cleanup Old Backups
# =====================================================
cleanup_old_backups() {
  log "INFO" "Starting cleanup of old backups..."
  # --- Keep last N daily backups ---
  local all_backups=($(ls -t ${BACKUP_DESTINATION}/backup-*.tar.gz 2>/dev/null))
  local total_backups=${#all_backups[@]}
  if [ "$total_backups" -gt "$DAILY_KEEP" ]; then
    for ((i=DAILY_KEEP; i<total_backups; i++)); do
      old_file="${all_backups[$i]}"
      log "INFO" "Deleting old backup: $old_file"
      rm -f "$old_file" "$old_file.sha256"
    done
  fi
  # --- Keep weekly backups (1 per week for last N weeks) ---
  find "$BACKUP_DESTINATION" -name "backup-*.tar.gz" -mtime +7 -type f | while read f; do
    file_date=$(basename "$f" | cut -d'-' -f2-4)
    week_num=$(date -d "$file_date" +%V 2>/dev/null)
    current_week=$(date +%V)
    if [ "$((current_week - week_num))" -gt "$WEEKLY_KEEP" ]; then
      log "INFO" "Deleting old weekly backup: $f"
      rm -f "$f" "$f.sha256"
    fi
  done
  # --- Keep monthly backups (1 per month for last N months) ---
  find "$BACKUP_DESTINATION" -name "backup-*.tar.gz" -mtime +30 -type f | while read f; do
    file_month=$(basename "$f" | cut -d'-' -f2)
    current_month=$(date +%m)
    if [ "$((10#$current_month - 10#$file_month))" -gt "$MONTHLY_KEEP" ]; then
      log "INFO" "Deleting old monthly backup: $f"
      rm -f "$f" "$f.sha256"
    fi
  done
  log "INFO" "Cleanup completed."
}
# =====================================================
# Function: Space Check (optional safety)
# =====================================================
check_disk_space() {
  local avail=$(df -k --output=avail "$BACKUP_DESTINATION" | tail -n1)
  if [ "$avail" -lt 100000 ]; then
    log "ERROR" "Not enough disk space for backup!"
    cleanup_exit 1
  fi
}
# =====================================================
# MAIN EXECUTION
# =====================================================
if [ "$MODE" == "backup" ]; then
  if [ -z "$SRC_DIR" ]; then
    echo "Usage: ./backup.sh [--dry-run] <source-folder>"
    cleanup_exit 1
  fi
  log "INFO" "Backup job started at $DATE_NOW"
  check_disk_space
  create_backup "$SRC_DIR"
  cleanup_old_backups
  log "INFO" "Backup job completed successfully."
elif [ "$MODE" == "restore" ]; then
  restore_backup "$BACKUP_FILE" "$RESTORE_DIR"
fi
# --- Cleanup and Exit ---
cleanup_exit 0
