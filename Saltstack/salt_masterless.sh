#!/bin/bash

# Configure a Standalone SaltStack Minion

# Help | Usage
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

This script configures a Free Spirit masterless SaltStack minion on the system.

Options:
  -h, --help      Show this help message and exit.
  -v, --verbose   Enable verbose output for debugging.
  -f, --force     Force the script to run even if connectivity checks fail.

EOF
}

# Main function
main() {
    check_sudo

    check_connectivity || { log "Exiting due to connectivity issues."; exit 1; }

    init_variables

    # Install/check pre-requisite packages (apt --quiet)
    sudo apt install -qqy "${PREREQ_PACKAGES[@]}" || { log "Cannot install pre-requisite apt packages"; exit 1; }

    # Check keyrings dir exists
    [[ -d /etc/apt/keyrings/ ]] || sudo mkdir -p /etc/apt/keyrings || { log "Cannot create keyrings directory in /etc/apt"; exit 1; }

    # Download public key
    get_and_save_source "$SALT_PUBKEY_URL" "$SALT_PUBKEY_PATH" "$SALT_PUBKEY_FILENAME" || { log "Cannot fetch salt public gpg key"; exit 1; }

    # Get apt repo sources
    get_and_save_source "$SALT_REPO_URL" "$SALT_REPO_PATH" || { log "Cannot fetch salt apt repo source"; exit 1; }

    # Install salt-minion
    sudo apt update -q &>/dev/null
    sudo apt install -qy salt-minion || { log "Cannot install salt minion"; exit 1; }

    # Configure Salt minion masterless
    SALT_CONFIG_ERR_MSG=$(echo $'\tCannot edit the /etc/salt/minion configuration file, \
    \tto make the server masterless, un-comment and set the </etc/salt/minion> option: \
    \t<file_client: local> ' | sed 's/\\//g')
    sudo sed -i 's/#file_client: remote/file_client: local/g' /etc/salt/minion || log "[WARN] $SALT_CONFIG_ERR_MSG "

    # Disable minion service since masterless
    ( sudo systemctl disable salt-minion && sudo systemctl stop salt-minion ) || log "[WARN] Cannot disable and restart salt-minion service, disable it to run salt-minion as standalone"

    # Create Salt directory
    [[ -d /srv/salt/ ]] || sudo mkdir -p /srv/salt || log "[WARN] Cannot create /srv/salt directory"

    # Copy SLS files to /srv if any
    { ls ./*.sls &>/dev/null && sudo cp ./*.sls /srv/salt; } || log "No SLS files to copy"
}

# Initialize variables
init_variables() {
    # Saltstack public key and OS keyring path
    SALT_PUBKEY_URL="https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public"
    SALT_PUBKEY_PATH="/etc/apt/keyrings"
    SALT_PUBKEY_FILENAME="salt-archive-keyring.pgp"
    # Saltstack package URL and path to apt sources
    SALT_REPO_URL="https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources"
    SALT_REPO_PATH="/etc/apt/sources.list.d"
    # pre-reqs
    PREREQ_PACKAGES=(ca-certificates curl gpg)
}

# Check if user has sudo NOPASSWD privileges
check_sudo_nopasswd() {
    { sudo -n true 2>/dev/null && { return 0; }; } || { return 1; }
}

# Check if script is run with sudo or has NOPASSWD privileges
check_sudo() {
    if [[ "$(/usr/bin/id -u)" -ne 0 ]]; then
        { check_sudo_nopasswd && { echo "... User has sudo NOPASSWD privileges. Continuing..."; } } || {
            echo "... sudo NOPASSWD is not set. Run the script with 'sudo'."
            exit 1
        }
    else
        echo "... Script is already running as root. Continuing..."
    fi
}

# Log messages with script name prefix
log() {
    local me
    me=$(basename "$0")
    echo "..[ $me ] $1"
}

# Check internet and APT repository connectivity
check_connectivity() {
    local ping_target="google.com"
    local ping_timeout=2
    # Check internet connectivity
    ping -c 1 -w "$ping_timeout" "$ping_target" &>/dev/null || {
        echo "... Error: No internet connectivity"
        return 1
    }
    # Check APT repository access
    sudo apt update -q &>/dev/null || {
        echo "... Error: APT repository access is not available."
        return 1
    }
    echo "... Internet and APT connectivity are OK."
    return 0
}

# Download and save a file
get_and_save_source() {
    local url="$1"
    local destination_dir="$2"
    local filename="${3:-$(basename "$url")}"
    # Logs if the URL is not accessible
    curl --head --silent --fail "$url" &>/dev/null || {
        echo "... Error: URL '$url' is not accessible."
        return 1
    }
    echo "... Downloading '$filename' from '$url'..."
    sudo curl -fsSL "$url" -o "$destination_dir/$filename" || {
        echo "... Error: Failed to download or save '$filename'"
        return 1
    }
    echo "... File '$filename' saved to '$destination_dir'."
    return 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            set -x
            ;;
        -f|--force)
            FORCE_MODE=true
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# Execute main function
main