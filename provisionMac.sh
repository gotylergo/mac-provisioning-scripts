#!/bin/bash

# Exit if script tries to use undeclared variables
set -o nounset

# Exit when a command fails
set -o errexit

echo "Provisioning Mac"

if [[ $EUID -ne 0 ]]; then
  echo "Please try again as root (sudo)"
  exit 126;
fi

## Stored functions

# Get hostname from user
function get_hostname () {
  osascript <<EOT
    tell application "Finder"
    activate
    set nameentry to text returned of (display dialog "What should the hostname be?" default answer "" with icon 2)
    end tell
EOT
}

# Get domain admin username
function get_domain_admin () {
  osascript <<EOT
    tell application "Finder"
    activate
    set nameentry to text returned of (display dialog "Enter your domain admin username" default answer "" with icon 2)
    end tell
EOT
}

# Get domain admin password
function get_domain_admin_pw () {
  osascript <<EOT
    tell application "Finder"
    activate
    set nameentry to text returned of (display dialog "Enter your domain admin password" default answer "" with icon 2)
    end tell
EOT
}

# Get the username of the person that will be using the Mac
function get_end_user () {
  osascript <<EOT
    tell application "Finder"
    activate
    set nameentry to text returned of (display dialog "Username of the end user" default answer "" with icon 2)
    end tell
EOT
}

# Get the password for the ssh_user user
function get_ssh_user_pw () {
  osascript <<EOT
    tell application "Finder"
    activate
    set nameentry to text returned of (display dialog "Enter ssh_user password" default answer "" with icon 2)
    end tell
EOT
}

# Get the fqdn
function get_fqdn () {
  osascript <<EOT
    tell application "Finder"
    activate
    set nameentry to text returned of (display dialog "Enter fqdn to join Mac to" default answer "" with icon 2)
    end tell
EOT
}

# Get variables needed for provisioning
echo "Getting Variables"
hostname="$(get_hostname)"
fqdn="$(get_fqdn)"
domain_admin="$(get_domain_admin)"
domain_admin_pw="$(get_domain_admin_pw)"
end_user="$(get_end_user)"
ssh_user_pw="$(get_ssh_user_pw)"

# Rename the Mac
echo "Renaming Mac"
scutil --set HostName "$hostname"
scutil --set LocalHostName "$hostname"
scutil --set ComputerName "$hostname"
echo "The new hostname is: $hostname"

# Join to domain and give domain admins local admin privileges
echo "Adding Mac to domain"
sudo dsconfigad -add $fqdn -computer $hostname -username $domain_admin -password $domain_admin_pw -mobile enable -mobileconfirm disable -useuncpath enable -groups "DOMAIN\domain admins"
sudo dsconfigad -packetsign require
sudo dsconfigad -packetencrypt require
domain_admin_pw=0
# Display login window as name and Password
defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Give end user local admin privileges
echo "Setting user as localadmin"
dseditgroup -o edit -a $end_user -t user admin
echo "$end_user is now a local admin"

# Create helpdesk accounts
echo "Creating unprivelidged helpdesk user"
username="helpdesk"
if [[ $username == `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $username` ]]; then
  echo "($username) already exists."
  exit 0
fi
real_name="helpdesk"
primary_group_id=20
LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
NextID=$((LastID + 1))
. /etc/rc.common
dscl . create /Users/$username
dscl . create /Users/$username RealName $real_name
password_hint="helpdesk"
dscl . create /Users/$username hint $password_hint
password_hint=0
password="helpdesk"
dscl . passwd /Users/$username $password
password=0
dscl . create /Users/$username UniqueID $NextID
dscl . create /Users/$username PrimaryGroupID $primary_group_id
dscl . create /Users/$username UserShell /bin/bash
dscl . create /Users/$username NFSHomeDirectory /Users/$username
createhomedir -u $username -c
echo "New user `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $username` has been created with unique ID `dscl . -list /Users UniqueID | grep -w $username | awk '{print $2}'`"

echo "Creating ssh_user user"
username="ssh_user"
if [[ $username == `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $username` ]]; then
    echo "User already exists!"
fi
real_name="ssh_user"
primary_group_id=80
LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
NextID=$((LastID + 1))
. /etc/rc.common
dscl . create /Users/$username
dscl . create /Users/$username RealName $real_name
password_hint="ssh_user"
dscl . create /Users/$username hint $password_hint
password_hint=0
dscl . passwd /Users/$username $ssh_user_pw
ssh_user_pw=0
dscl . create /Users/$username UniqueID $NextID
dscl . create /Users/$username PrimaryGroupID $primary_group_id
dscl . create /Users/$username UserShell /bin/bash
dscl . create /Users/$username NFSHomeDirectory /Users/$username
createhomedir -u $username -c
echo "New user `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $username` has been created with unique ID `dscl . -list /Users UniqueID | grep -w $username | awk '{print $2}'`"

# Enable ssh for lansweeper user
echo "Enabling SSH for ssh_user user"
systemsetup -setremotelogin on
dseditgroup -o create -q com.apple.access_ssh
dseditgroup -o edit -a ssh_user -t user com.apple.access_ssh

# Run Mac software updater
echo "Running updates"
sudo softwareupdate -i -a
