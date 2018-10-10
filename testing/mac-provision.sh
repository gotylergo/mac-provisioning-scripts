#!/bin/bash

echo "Provisioning Mac"

if [[ `id -u` != 0 ]]; then
    echo "Must be root to run script"
    exit
fi

echo "Rename Mac"

###functions
function machinename () {
    osascript <<EOT
        tell application "Finder"
            activate
            set nameentry to text returned of (display dialog "Please Input New Computer Name" default answer "" with icon 2)
            end tell
EOT
}

function renameComputer(){
    #Set New Computer Name
    echo "The New Computer name is: $ComputerName"
    scutil --set HostName $ComputerName
    scutil --set LocalHostName $ComputerName
    scutil --set ComputerName $ComputerName

    echo Rename Successful
}

###Script
echo "Provisioning Mac"
echo
echo "Renaming computer"
echo
ComputerName=$(machinename)
renameComputer
exit 0

echo "Creating accounts"
echo "Creating helpdesk user"

UserName="helpdesk"

if [[ $UserName == `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` ]]; then
    echo "User already exists!"
    exit 0
fi

RealName="helpdesk"
PrimaryGroupID=20
LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
NextID=$((LastID + 1))

. /etc/rc.common
dscl . create /Users/$UserName
dscl . create /Users/$UserName RealName $RealName

PasswordHint="helpdesk"
dscl . create /Users/$UserName hint $PasswordHint
PasswordHint=0

AccountPassword="helpdesk"
dscl . passwd /Users/$UserName $AccountPassword
AccountPassword=0
dscl . create /Users/$UserName UniqueID $NextID
dscl . create /Users/$UserName PrimaryGroupID $PrimaryGroupID
dscl . create /Users/$UserName UserShell /bin/bash
dscl . create /Users/$UserName NFSHomeDirectory /Users/$UserName
createhomedir -u $UserName -c

echo "New user `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` has been created with unique ID `dscl . -list /Users UniqueID | grep -w $UserName | awk '{print $2}'`"
echo "Creating asset user"

UserName="asset"

if [[ $UserName == `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` ]]; then
    echo "User already exists!"
    exit 0
fi

RealName="asset"
PrimaryGroupID=80
LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
NextID=$((LastID + 1))

. /etc/rc.common
dscl . create /Users/$UserName
dscl . create /Users/$UserName RealName $RealName

PasswordHint="asset"
dscl . create /Users/$UserName hint $PasswordHint
PasswordHint=0

function assetpassword () {
    osascript <<EOT
        tell application "Finder"
            activate
            set nameentry to text returned of (display dialog "Enter asset password from secrepo" default answer "" with icon 2)
            end tell
EOT
}

AccountPassword=$(assetpassword)
# read -p "asset password from SecRepo: " AccountPassword
dscl . passwd /Users/$UserName $AccountPassword
AccountPassword=0
dscl . create /Users/$UserName UniqueID $NextID
dscl . create /Users/$UserName PrimaryGroupID $PrimaryGroupID
dscl . create /Users/$UserName UserShell /bin/bash
dscl . create /Users/$UserName NFSHomeDirectory /Users/$UserName
createhomedir -u $UserName -c

echo "New user `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` has been created with unique ID `dscl . -list /Users UniqueID | grep -w $UserName | awk '{print $2}'`"



echo "Running updates"

sudo softwareupdate -i -a and press Enter
