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

apt-get update && apt-get -y upgrade && apt-get update

apt -y install curl wget apache2-utils default-jre default-jdk wget git vim nano make g++ net-tools iproute2 libssl-dev tcpdump jq iputils-ping apt-transport-https nghttp2-client bash-completion xauth gcc autoconf libtool pkg-config sshpass python3 python3-setuptools python3-pip qt5-default

cd /opt && git clone https://github.com/UmakantKulkarni/scripts

wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-ppc64le.sh -O miniconda.sh

bash miniconda.sh

rm miniconda.sh
echo export IBM_POWERAI_LICENSE_ACCEPT=yes >> ~/.bashrc
source ~/.bashrc

conda config --add default_channels https://repo.anaconda.com/pkgs/main
conda config --prepend channels https://public.dhe.ibm.com/ibmdl/export/pub/software/server/ibm-ai/conda/

conda create -n ai python=3.7
conda activate ai
conda install --strict-channel-priority tensorflow-gpu

pip3 install gdown
conda install -c conda-forge matplotlib-base pandas scikit-learn

echo "Finished running setup-node.sh"
