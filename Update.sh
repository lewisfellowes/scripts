#!/bin/bash
hostname=$(hostname)
echo "This is host $hostname"
# Run apt update and capture the output
output=$(sudo apt update 2>&1)

# Check for errors during the update process
if echo "$output" | grep -q "Err:"; then
    echo "An error occurred while running 'apt update'."
    exit 1
fi

# Check if there are any packages available for upgrade
if echo "$output" | grep -q "packages can be upgraded"; then
    echo "Packages can be upgraded. Proceeding with upgrade..."

    # Run apt upgrade and capture the output of upgraded packages
    upgrade_output=$(NEEDRESTART_MODE=a sudo apt upgrade -y 2>&1)

    # Filter out the lines that show the packages being upgraded
    upgraded_packages=$(echo "$upgrade_output" | grep -E "^(Setting up|Preparing to unpack|Unpacking) ")

    # Check if any packages were upgraded
    if [ -n "$upgraded_packages" ]; then
        echo "Upgraded packages:"
        echo "$upgraded_packages" | awk '{print $NF}' | sort | uniq
    else
        echo "No packages were upgraded."
    fi
else
    echo "No packages need to be upgraded."
fi
