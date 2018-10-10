#!/bin/bash

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