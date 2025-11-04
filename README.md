Project Overview

You need to create a Bash script (backup.sh) that automatically backs up folders, manages old backups, verifies their integrity, and logs everything.
It should be a smart backup system — like an automated, reliable “copy & paste” tool.

Main Features (What Your Script Must Do)
1. Create Backups

Take a folder as input (e.g. ./backup.sh /home/user/documents).

Create a compressed file (.tar.gz) named with the current date/time
→ Example: backup-2024-11-03-1430.tar.gz.

Generate a checksum file (.md5 or .sha256) to verify backup integrity.

Skip unnecessary folders (like .git, node_modules, .cache).

2. Delete Old Backups Automatically

To save space, delete older backups using a retention policy:

Keep last 7 daily backups

Keep last 4 weekly backups

Keep last 3 monthly backups
→ Delete anything older than these.

3. Verify Backups

After creating each backup:

Recalculate checksum and compare.

Try extracting a test file.

Print “SUCCESS” if it’s good, “FAILED” if corrupted.

4. Smart Features
A. Configuration File (backup.config)

Store settings (not inside script):

BACKUP_DESTINATION=/home/backups
EXCLUDE_PATTERNS=".git,node_modules,.cache"
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3

B. Logging

Everything should be logged to backup.log with timestamps, actions, results, and errors.

C. Dry Run Mode

Run in test mode (--dry-run) to show what would happen without doing it.

D. Prevent Multiple Runs

Use a lock file (/tmp/backup.lock) so the script can’t run twice at the same time.

Extra (Optional) Features

If you want bonus points:

Restore backups → ./backup.sh --restore backup-file --to /path

List all backups → ./backup.sh --list

Check available disk space

Send email notifications (simulate using a text file)

Incremental backups (only copy changed files)

Error Handling

Your script should handle problems gracefully:

Missing folder → print “Error: Source folder not found”

Permission denied

Not enough disk space

Missing config file

Missing backup destination → create automatically

Interrupted script → clean up partial files

Project Files
backup-system/
├── backup.sh          # Main script
├── backup.config      # Config file
└── README.md          # Documentation

README.md Must Include

A. Overview: What the script does and why

B. Usage: How to install, run, and all options

C. How It Works: Logic for rotation, checksum, structure

D. Design Decisions: Why you chose this approach

E. Testing: How you tested with examples

F. Known Issues: What can be improved

🧍‍♂️ What You Must Demonstrate

Creating backups

Multiple backups over fake “days”

Automatic old backup deletion

Dry run mode

Error handling

(Optional) Restore functionality

Grading Breakdown
Category	Weight	Description
Code Works Correctly	30%	Features work without errors
Code Quality	25%	Clean, well-structured, commented
Error Handling	20%	Proper error messages, no crashes
Documentation	15%	Clear README & examples
Configuration	10%	Uses external config properly
Bonus, For extra smart features
Tips

Start small and test each part.

Use functions for each feature.

Log everything.

Test your script regularly.

Use GitHub for version control.

In Short

You are building a fully automated, configurable, and reliable backup system in Bash that:

Backs up data

Verifies integrity

Manages old backups

Logs everything

Can be customized with a config file
Optionally, it can also restore, list, and check space.
