#! /bin/bash

echo "Hello, we are going to start the setup of the tool chain"
echo -e "needed to start developing.\n"
FG_RED="\e[31m"
RESET="\e[0m"

# test if you are super user
if [[ $EUID -ne 0 ]]; then
   echo -e $FG_RED"Please run this script as root"$RESET 1>&2
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

# check for git
echo "Checking git 1.7.9+ ..."
GIT_VERSION=`which git`
if [ $? -ne 0 ]; then
    echo "Instaling git"
    apt-get --yes install git git-man liberror-perl patch gitk git-svn git-gui
    # Redhat/fedora/CentOS yum install git-core
    if [ $? -ne 0 ]; then
        echo -e "\nPlease install git 1.7.9 or greater to continue\n"
        echo -e "\n sudo apt-get --yes install git git-man liberror-perl patch gitk git-svn git-gui\n"
        exit 1
    fi
fi


echo "$HOME : $SUDO_USER"

ANSIBLE_DIR="$HOME/workspace/src/ansible"
sudo -u $SUDO_USER mkdir -p "$ANSIBLE_DIR"

echo "Installing Ansible"
# set the ‘ansible_python_interpreter’ variable in inventory


echo "Cloning Ansible repository"
sudo -u $SUDO_USER git clone git://github.com/ansible/ansible.git $ANSIBLE_DIR 2> /dev/null

if [ $? -ne 0 ]; then
    echo "Git can't clone the repository, probably it already exist, trying to update it"
fi

# Go to ansible directory
cd $ANSIBLE_DIR

sudo -u $SUDO_USER git pull

# TODO: fix this to not need to run it manually
echo "Please source your current shell, running the following command:"
echo -e "\n\$ source $ANSIBLE_DIR/hacking/env-setup\n"

source $ANSIBLE_DIR/hacking/env-setup

ANSIBILIZED="./.ansibilized~"

if [ ! -e $ANSIBILIZED ]; then
    # mark this as ansibilized
    echo "setting ansible"
    echo -e "\nsource $ANSIBLE_DIR/hacking/env-setup > /dev/null\n" >> ~/.bashrc
    sudo -u $SUDO_USER touch $ANSIBILIZED
fi

# go to nexus home ~/workspace/nexus
NEXUS_HOME="$HOME/workspace/nexus"
cd $NEXUS_HOME
if [ $? -ne 0 ]; then
    # if the path doesn't exists then we create it
    mkdir $NEXUS_HOME
    cd $NEXUS_HOME
fi

# Refresh the
# this is safe to run, even if we do have one created already
git init

#if it already exists we are ignoring it, and continue to pull
git remote add origin https://github.com/NetoBuenrostro/nexus.git

git branch --set-upstream-to=origin/master master

git pull

# Check for wget

wget --version
if [ $? -ne 0 ]; then
    echo "Installing wget"
    sudo apt-get --yes install wget
fi


# Install virtual box 4.3.10
VIRTUALBOX="http://download.virtualbox.org/virtualbox/4.3.10/virtualbox-4.3_4.3.10-93012~Ubuntu~raring_amd64.deb"

# TODO: this may break with a version like 4.12, but I haven't seen any like that yet
echo "Checking virtualbox"
VBOX_VERSION=$(vboxmanage --version 2>/dev/null | cut -b 1-3)
if [ $? -ne 0 ]; then
    echo "Installing virtualbox"
    sudo -u $SUDO_USER wget -c $VIRTUALBOX -O /tmp/virtualbox.deb
    dpkg -i /tmp/virtualbox.deb
else
    case "$VBOX_VERSION" in
        "4.0" | "4.1" | "4.2" | "4.3" )
            # you are good to go
            ;;
        *)
            echo -e "$FG_RED You need to install any of those versions for Virtual box:"
            echo -e "4.0.x | 4.1.x | 4.2.x | 4.3.x"$RESET
            ;;
    esac
fi


VAGRANTUP="https://dl.bintray.com/mitchellh/vagrant/vagrant_1.5.3_x86_64.deb"
echo "checking for vagrant"
vagrant --version >/dev/null
if [ $? -ne 0 ]; then
    echo "installing vagrantup"
    sudo -u $SUDO_USER wget -c $VAGRANTUP -O /tmp/vagrantup.deb
    dpkg -i /tmp/vagrantup.deb
fi
