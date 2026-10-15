# Lynis Security Enhancements

This repository contains two custom Bash audit scripts developed to enhance Linux security auditing using Lynis-related security checks.

## Scripts

### 1. Automatic Security Updates Audit

**File:** `tests_auto_updates_custom.sh`

**Test ID:** `CUST-9001`

Checks whether the unattended-upgrades package is installed, verifies effective APT automatic-update settings, checks the APT upgrade timer configuration, and looks for the unattended-upgrades log file.

### 2. Automatic Update Service Status Audit

**File:** `tests_update_service_custom.sh`

**Test ID:** `CUST-9003`

Checks the installation of the unattended-upgrades package and examines the enabled and active status of the APT update timers. It also checks whether the automatic upgrade service is reported as failed.

## Running the Scripts

Run the scripts individually using Bash:

```bash
sudo bash tests_auto_updates_custom.sh
```

```bash
sudo bash tests_update_service_custom.sh
```

## Notes

- These are standalone Bash audit scripts.
- The scripts report PASS and WARNING results based on the checks performed.
- They do not automatically modify system security settings.
- Results depend on the Linux distribution, installed packages, service configuration, and system state.
- A WARNING indicates that a check did not meet its expected condition; it does not necessarily mean that the entire system is insecure.
