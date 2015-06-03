#!/bin/bash
#
# Installs the butterfly console.  Assumes it is installed on a node
# running a XAP lookup service

function error_exit {
   ctx logger error "$2 : error code: $1"
   exit ${1}
}

demo_url=$(ctx node properties demo_url)
butterfly_repo=$(ctx node properties butterfly_repo)

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

if [ ! -d /tmp/demodl ]; then
  DLDIR=/tmp/demodl
  mkdir $DLDIR
  pushd $DLDIR
  wget "${demo_url}"
  unzip *.zip
  chmod +x *.sh
fi

if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y update
else
   ctx logger info "running apt-get update"
   sudo apt-get clean all
   sudo dpkg --configure -a
   sudo apt-get -qq update
   ctx logger info "installing python-setuptools with apt-get"
   sudo apt-get install python-setuptools -y || error_exit $? "Failed to install requirements ( python-setuptools)"
fi

sudo easy_install virtualenv || error_exit $? "Failed on: easy_install virtualenv"
virtualenv /tmp/virtenv_is --no-site-packages || error_exit $? "Failed on: virtualenv virtenv"
source /tmp/virtenv_is/bin/activate

if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y update
   sudo yum -y install git python-pip gcc python-devel openssl-devel || error_exit $? "Failed to install requirements (git python-pip gcc python-devel)"
else
   ctx logger info "running apt-get update"
   sudo apt-get clean all
   sudo dpkg --configure -a
   sudo apt-get -qq update
   ctx logger info "installing misc with apt-get"
   sudo apt-get -qq install git python-pip gcc python-dev libssl-dev || error_exit $? "Failed to install requirements (git python-pip gcc python-devel)"
   ctx logger info "installing openssl with pip"
fi
pip install pyOpenSSL==0.12 || error_exit $? "Failed to install pyOpenSSL v0.12"
   ctx logger info "cloning butterfly repo from ${butterfly_repo}"
cd /tmp/demodl/
git clone "${butterfly_repo}" || error_exit $? "Failed to clone butterfly repository"
cd butterfly/ || error_exit $? "Failed to cd butterfly"
   ctx logger info "installing butterfly"
python setup.py install || error_exit $? "Failed on: python setup.py install"
   ctx logger info "done installing butterfly"
deactivate


