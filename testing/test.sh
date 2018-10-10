#!/bin/bash
echo "Setting user as local admin"
echo ""
echo "Please enter the username to make a local admin -> 
read domainUser
# dseditgroup -o edit -a $domainUser -t user admin
echo "Domain User: $domainUser"
