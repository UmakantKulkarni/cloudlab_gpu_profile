#!/usr/bin/bash

set -ex

# Log output of this script to syslog.
# https://urbanautomaton.com/blog/2014/09/09/redirecting-bash-script-output-to-syslog/
exec 1> >(logger -s -t $(basename $0)) 2>&1

PROJ_GROUP="$1"

# whoami
echo "Running as $(whoami) with groups ($(groups))"

# i am root now
if [[ $EUID -ne 0 ]]; then
  echo "Escalating to root with sudo"
  exec sudo /bin/bash "$0" "$@"
fi

# am i done
if [[ -f /.setup-done ]]; then
  echo "Found /.setup-done, exit."
  exit
fi

cd /opt/scripts && git pull

apt-get update && apt-get -y upgrade && apt-get update

apt -y install curl wget apache2-utils default-jre default-jdk wget git vim nano make g++ net-tools iproute2 libssl-dev tcpdump jq iputils-ping apt-transport-https nghttp2-client bash-completion xauth gcc autoconf libtool pkg-config sshpass python3 python3-setuptools python3-pip qt5-default

pip3 install h2 numpy scipy pandas matplotlib scikit-learn gdown pyqt5 opencv-python

# cuda driver
if lspci | grep -q -i nvidia; then
  apt-get purge -y nvidia* libnvidia*
  apt-get install -y linux-headers-$(uname -r)
  apt-get install -y nvidia-headless-470-server nvidia-utils-470-server

  rmmod nouveau || true
  modprobe nvidia || true
fi

echo "Finished running setup-node.sh"
