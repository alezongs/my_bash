
# SaltStack Minion Configuration Script

This (Redundant) script automates the configuration of a standalone SaltStack minion on a Debian/Ubuntu-based system. It installs the necessary prerequisites, sets up the SaltStack repository, and configures the minion to run in masterless mode.

The Official Saltstack Quickstart script to install a masterless minion is here: [Salt Masterless Quickstart](https://docs.saltproject.io/en/master/topics/tutorials/quickstart.html#salt-masterless-quickstart)

---

## Table of Contents
1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Usage](#usage)
4. [Configuration Variables](#configuration-variables)
5. [Logging](#logging)
6. [Troubleshooting](#troubleshooting)
7. [License](#license)

---

## Features
- Installs prerequisite packages (`ca-certificates`, `curl`, `gpg`).
- Downloads and configures the SaltStack GPG key and repository.
- Installs the `salt-minion` package.
- Configures the minion to run in masterless mode.
- Disables the `salt-minion` service (since it runs standalone).
- Creates the `/srv/salt` directory and copies any `.sls` files present in the current directory.

---

## Prerequisites
- A Debian/Ubuntu-based system.
- Internet connectivity.
- Sudo privileges with or without `NOPASSWD`.

---

## Usage

### Running the Script
1. Clone or download the script to your system.
2. Make the script executable:
   ```bash
   chmod +x configure_salt_minion.sh
   ```
3. Run the script with sudo:
   ```bash
   sudo ./configure_salt_minion.sh
   ```

### Command-Line Options
- `-h` or `--help`: Display the help message and exit.
- `-v` or `--verbose`: Enable verbose output for debugging.
- `-f` or `--force`: Force the script to run even if connectivity checks fail (not implemented by default).

Example:
```bash
sudo ./configure_salt_minion.sh --verbose
```

---

## Configuration Variables

The script uses several variables to configure the SaltStack GPG key, repository, and prerequisite packages. These variables are defined in the `init_variables()` function within the script.

### GPG Key and Repository Configuration
- **SALT_PUBKEY_URL**: URL to the SaltStack GPG public key.
  ```bash
  SALT_PUBKEY_URL="https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public"
  ```
- **SALT_PUBKEY_PATH**: Directory where the GPG key will be saved.
  ```bash
  SALT_PUBKEY_PATH="/etc/apt/keyrings"
  ```
- **SALT_PUBKEY_FILENAME**: Name of the GPG key file.
  ```bash
  SALT_PUBKEY_FILENAME="salt-archive-keyring.pgp"
  ```
- **SALT_REPO_URL**: URL to the SaltStack APT repository source file.
  ```bash
  SALT_REPO_URL="https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources"
  ```
- **SALT_REPO_PATH**: Directory where the repository source file will be saved.
  ```bash
  SALT_REPO_PATH="/etc/apt/sources.list.d"
  ```

### Prerequisite Packages
- **PREREQ_PACKAGES**: List of packages required for the script to run.
  ```bash
  PREREQ_PACKAGES=(ca-certificates curl gpg)
  ```

---

## Logging
The script logs its output to the terminal, prefixed with the script name for clarity. Example:
```
..[ configure_salt_minion.sh ] Internet and APT connectivity are OK.
```

---

## Troubleshooting
1. **Connectivity Issues**:
   - Ensure the system has internet access.
   - Check if the URLs in `init_variables()` are accessible.

2. **Sudo Privileges**:
   - If the script fails due to sudo privileges, ensure you have `NOPASSWD` configured or run the script with `sudo`.

3. **Verbose Output**:
   - Use the `-v` or `--verbose` option to enable debug output and identify issues.

4. **File Permissions**:
   - Ensure the script has execute permissions (`chmod +x configure_salt_minion.sh`).

---

## License
This script is provided under the [Apache License](https://www.apache.org/licenses/LICENSE-2.0). Feel free to modify and distribute it as needed.

---

## Contributing
If you find any issues or have suggestions for improvement, please open an issue or submit a pull request.

---

This README provides a comprehensive guide for users to understand, configure, and use your script effectively. Let me know if you need further adjustments!
