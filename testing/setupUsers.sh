#!/bin/sh

if [[ `id -u` != 0 ]]; then
    echo "Must be root to run script"
    exit
fi

echo "Creating accounts"
echo " "

echo "Creating helpdesk user"
echo " "

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

echo " "
AccountPassword="helpdesk"
dscl . passwd /Users/$UserName $AccountPassword
AccountPassword=0
echo " "
dscl . create /Users/$UserName UniqueID $NextID
dscl . create /Users/$UserName PrimaryGroupID $PrimaryGroupID
dscl . create /Users/$UserName UserShell /bin/bash
dscl . create /Users/$UserName NFSHomeDirectory /Users/$UserName
createhomedir -u $UserName -c

echo " "
echo "New user `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` has been created with unique ID `dscl . -list /Users UniqueID | grep -w $UserName | awk '{print $2}'`"

echo "Creating ibasset user"
echo " "

UserName="ibasset"

if [[ $UserName == `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` ]]; then
    echo "User already exists!"
    exit 0
fi

RealName="ibasset"
PrimaryGroupID=80
LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
NextID=$((LastID + 1))

. /etc/rc.common
dscl . create /Users/$UserName
dscl . create /Users/$UserName RealName $RealName

PasswordHint="helpdesk"
dscl . create /Users/$UserName hint $PasswordHint
PasswordHint=0

echo " "
read -p "ibasset password from SecRepo: " AccountPassword
dscl . passwd /Users/$UserName $AccountPassword
AccountPassword=0
echo " "
dscl . create /Users/$UserName UniqueID $NextID
dscl . create /Users/$UserName PrimaryGroupID $PrimaryGroupID
dscl . create /Users/$UserName UserShell /bin/bash
dscl . create /Users/$UserName NFSHomeDirectory /Users/$UserName
createhomedir -u $UserName -c

echo " "
echo "New user `dscl . -list /Users UniqueID | awk '{print $1}' | grep -w $UserName` has been created with unique ID `dscl . -list /Users UniqueID | grep -w $UserName | awk '{print $2}'`"
#
#
# echo " "
# echo "Creating ibasset user"
#
# . /etc/rc.common
# dscl . create /Users/administrator
# dscl . create /Users/administrator RealName "ibasset"
# dscl . create /Users/administrator hint " "
# read -p "ibasset password from SecRepo: " AccountPassword
# dscl . passwd /Users/administrator $AccountPassword
# dscl . create /Users/administrator UniqueID 501
# dscl . create /Users/administrator PrimaryGroupID 80
# dscl . create /Users/administrator UserShell /bin/bash
# dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
# cp -R /System/Library/User\ Template/English.lproj /Users/administrator
# chown -R administrator:staff /Users/administrator
#
# echo " "
# echo "New user ibasset created"
