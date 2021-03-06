#!/bin/bash
GRUB="/etc/default/grub"
VERSION="4.9.0-4"

  while getopts ":iu" opt; do
  case $opt in
  i)

  # Make sure only root can run the script
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, su to become root" 1>&2
    exit 1
  fi

  # Checking if curl is installed
  if [ ! -x  /usr/bin/curl ]; then
    echo -e "\033[31mcurl Command Not Found\e[0m"
    echo -e "\033[34mInstalling curl, Please Wait...\e[0m"
    apt-get install curl
  fi

  # Fetching the latest script version
  read -p "Do you want to grab the latest version of the script? *RECOMMENDED* (Y/N) " REPLY
  if [ "${REPLY,,}" == "y" ]; then
    curl https://raw.githubusercontent.com/lunarthegrey/debian-grsec/master/debian-grsec.sh -o /root/debian-grsec.sh
    echo "Please re-run the script: bash /root/debian-grsec.sh"
  exit
  fi

  # Updating / Upgrading System
  read -p "Do you wish to upgrade system packages? (Y/N) " REPLY
  if [ "${REPLY,,}" == "y" ]; then
    apt-get update
    apt-get dist-upgrade
  fi
    
  # Force stable package prefences, for some reason only works with apt-get
  read -p "Do you want to force stable packages system wide? *RECOMMENDED* (Y/N) " REPLY
  if [ "${REPLY,,}" == "y" ]; then
cat << EOF > /etc/apt/preferences.d/force-stable
  Package: *
  Pin: release a=stable
  Pin-Priority: 1001
EOF
  fi

  # Add sid to sources.list and apt-get update
  read -p "Do you want to add the Debian sid repository? *REQUIRED* (Y/N) " REPLY
  if [ "${REPLY,,}" == "y" ]; then
    echo "deb http://http.debian.net/debian/ sid main contrib" > /etc/apt/sources.list.d/sid.list
    apt-get update
  fi

  # Check if you're on 32bit or 64bit, install the correct kernel from sid and add it to grub
  MACHINE_TYPE=`uname -m`
  if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    apt-get -t sid install -y linux-image-grsec-amd64
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-amd64"/g' $GRUB
    update-grub
  else
    apt-get -t sid install -y linux-image-grsec-i386
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-i386"/g' $GRUB
    update-grub
  fi

  read -p "To boot from the new kernel you'll need to reboot, do you want to? (Y/N) " REPLY
  if [ "${REPLY,,}" == "y" ]; then
    sync
    reboot
  fi
  ;;

  u)
  
  apt-get update
  
  # Check if you're on 32bit or 64bit, install the correct kernel from sid and add it to grub
  MACHINE_TYPE=`uname -m`
  if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    apt-get -t sid install -y linux-image-grsec-amd64 linux-image-{$VERSION}-grsec-amd64
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-amd64"/g' $GRUB
    update-grub
  else
    apt-get -t sid install -y linux-image-grsec-i386 linux-image-{$VERSION}-grsec-i386
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-i386"/g' $GRUB
    update-grub
  fi
  ;;

  \?)
    echo "Invalid option: -$OPTARG" >&2
  ;;
 esac
done
