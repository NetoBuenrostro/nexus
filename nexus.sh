#! /bin/bash

echo "Hello, we are going to start the setup of the tool chain"
echo -e "needed to start developing.\n"

# test if you are super user
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root" 1>&2
   exit 1
fi

