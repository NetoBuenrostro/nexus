#! /bin/bash

echo "Hello, we are going to start the setup of the tool chain"
echo -e "needed to start developing.\n"

# test if you are super user
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root" 1>&2
   exit 1
fi

echo "Checking python2.7+ ..."
# check for git
echo "Checking git 1.7.9+ ..."
GIT_VERSION=`which python`
if [ $? -ne 0 ]; then
    echo "Instaling python"
    apt-get --yes install python2.7
    if [ $? -ne 0 ]; then
        echo -e "\nPlease install python 2.7 or greater but lower than python 3 to continue\n"
        echo -e "\n sudo apt-get --yes install python2.7\n"
        exit 1
    fi
fi
PYTHON_VER=`python -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`


PYTHON_MIN_VER="2.7"
PYTHON_MAX_VER="3.0" # not 3 should be lower than 3


if [[ "$PYTHON_MAX_VER" < "$PYTHON_VER" ]]; then
    echo "Python must be 2.x, 3 is not supported yet in ansible"
    echo "Instaling python2.7"
    apt-get --yes install python2.7
    if [ $? -ne 0 ]; then
        echo -e "\nPlease install python 2.7 or greater but lower than python 3 to continue\n"
        echo -e "\n sudo apt-get --yes install python2.7\n"
        exit 1
    fi
else
    echo "Python $PYTHON_VER found."
fi

PYTHON_VER=`python -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`


if [[ "$PYTHON_VER" < "$PYTHON_MIN_VER" ]]; then
    echo "Instaling python2.7"
    apt-get --yes install python2.7
    if [ $? -ne 0 ]; then
        echo -e "\nPlease install python 2.7 or greater but lower than python 3 to continue\n"
        echo -e "\n sudo apt-get --yes install python2.7\n"
        exit 1
    fi
else
    echo "Python $PYTHON_VER found."
fi

