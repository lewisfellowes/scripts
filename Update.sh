#!/bin/bash
#v4 from VSCode PR
# Test PR from lewis fork
# Test 2 - PR as a contributor - directly in original repo
# Test 1 JW Approver

# Print hostname
hostname=$(hostname)
echo "Host: $hostname"

# Host maintenance
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
    upgraded_packages=$(echo "$upgrade_output" | grep -E "^Inst|^Conf|^Unpacking|^Setting up")

    # Check if any packages were upgraded
    if [ -n "$upgraded_packages" ]; then
        echo "Upgraded packages:"
        echo "$upgraded_packages" | awk '{print $2}' | sort | uniq
    else
        echo "No packages were upgraded."
    fi
else
    echo "No packages need to be upgraded."
fi


# Docker maintenance - Only run this if it's Sunday
# Get the day of the week (0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thur, 5=Fri, 6=Sat)
day_of_week=$(date +%w)
if [ "$day_of_week" -eq 0 ]; then
    echo "Today is Sunday. Performing Docker maintenance."

    # Check for Docker
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed on $hostname. Skipping Docker maintenance."
        exit 0
    else
        echo "Docker is installed. Performing Docker maintenance."

        # Check current Docker version
        docker_version=$(docker --version)
        echo "Current Docker version: $docker_version"

        # Update Docker if necessary and capture the output
        echo "Checking for Docker updates."
        docker_update_output=$(sudo apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io -y 2>&1)

        # Filter out the lines that show the packages being upgraded
        docker_upgraded_packages=$(echo "$docker_update_output" | grep -E "^(Setting up|Preparing to unpack|Unpacking) ")

        # Check if any Docker components were upgraded
        if [ -n "$docker_upgraded_packages" ]; then
            echo "Docker components upgraded:"
            echo "$docker_upgraded_packages" | awk '{print $NF}' | sort | uniq
        else
            echo "No Docker components were upgraded."
        fi

        # Restart running Docker containers
        echo "Restarting all running Docker containers."
        docker restart $(docker ps -q)

    fi
fi
