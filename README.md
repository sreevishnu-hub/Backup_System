# 🗂️ Automated Backup System

An **automated backup tool** built using **Bash scripting** that safely creates and manages backups of important files or folders.  
This project automatically copies your data, stores it securely, verifies the integrity of each backup, and manages old backups efficiently.

---

## 🚀 Project Overview

The **Backup System** automates the process of backing up directories on your system.  
It ensures your data is **safe, verified, and easy to restore** by performing these key actions:

- 📁 Creates timestamped backup files.
- ✅ Verifies the integrity of backups using checksum validation.
- 🧹 Automatically removes older backups to save disk space.
- 🧾 Logs all backup activities for tracking and debugging.

This tool is ideal for Linux users, system administrators, and developers who want a **simple yet reliable** backup automation system.
---
## 📦 Project Structure
Backup_System/
│
├── backups/ # Stores all generated backup .tar.gz files
├── logs/ # Contains log files of each backup operation
├── test_data/ # Sample folder to test the backup script
│
├── backup.sh # Main Bash script that performs the backup process
├── backup.config # Configuration file for setting backup parameters
└── README.md # Project documentation (this file)
---
## ⚙️ Features

### 🧰 1. Automated Backup Creation
- Takes the target folder as input.
- Compresses the folder into a `.tar.gz` file with a timestamp.
- Saves backups in the `backups/` directory.

### 🔐 2. Checksum Verification
- Generates a `.sha256` checksum for every backup file.
- Ensures data integrity — verifies that backups are not corrupted.

### 🧾 3. Logging System
- Records all actions (success or failure) with timestamps.
- Stores logs in the `logs/` folder for future reference.

### ♻️ 4. Cleanup of Old Backups
- Automatically deletes backups older than a defined number of days (customizable in `backup.config`).

### ⚡ 5. Configuration File
- `backup.config` lets you easily customize:
  - Backup source directory
  - Backup destination folder
  - Log file path
  - Retention policy (number of days to keep backups)
---
## 🧩 How It Works
1. The user specifies the folder to back up.
2. The script compresses that folder and stores it in `backups/` with the current date and time in the filename.
3. A SHA256 checksum file is created for integrity verification.
4. The backup operation is logged in `logs/`.
5. If enabled, old backups beyond the retention period are automatically removed.
---
## 🛠️ Usage Instructions

### 1. Make the Script Executable
```bash
chmod +x backup.sh

**Run the Backup Script**:
./backup.sh <folder_to_backup>
**Example**:
./backup.sh test_data
**Check the Logs **:
cat logs/backup-<timestamp>.log
**Verify Backup Integrity (Optional)**:
sha256sum -c backups/backup-<timestamp>.tar.gz.sha256

**Configuration Example (backup.config)**:

# Configuration file for Automated Backup System
# Source folder to back up
SOURCE_DIR="test_data"
# Destination folder for backups
BACKUP_DIR="backups"
# Log file location
LOG_DIR="logs"
# Number of days to keep old backups
RETENTION_DAYS=7

**Technologies Used**:

Bash Scripting – Automates all operations
tar – Compresses files and folders
sha256sum – Verifies data integrity
cron (optional) – Schedule automatic backups

**Future Enhancements**:

Email notifications after each backup
Remote backup storage (AWS S3, Google Drive, etc.)
Incremental backup support
Web-based dashboard for monitoring backup status

**Conclusion**:

This Automated Backup System simplifies the process of safeguarding important data through automation, verification, and logging. It’s a lightweight, easy-to-customize, and reliable solution for everyday backup tasks.
