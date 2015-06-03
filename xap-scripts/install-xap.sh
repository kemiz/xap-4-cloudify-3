#!/bin/bash
set -x
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

download_url=$(ctx node properties download_url)
license_key=$(ctx node properties license_key)

ctx logger info "getting java"
# Get Java
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y -q install java-1.7.0-openjdk || exit $?   
else
   sudo apt-get update
   sudo apt-get -f install libdevmapper-event1.02.1
   sudo apt-get -qq --no-upgrade install openjdk-7-jdk || exit $?   
fi

ctx logger info "getting unzip"
# Get Unzip
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y -q install unzip || exit $?   
else
   sudo apt-get -qq -f --no-upgrade install unzip || exit $?
fi

# Set runtime properties
interfacename=$(ctx node properties interfacename)
ctx logger info "INTERFACENAME: ${interfacename}"
IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
ctx logger info "About to post IP address ${IP_ADDR}"

ctx instance runtime-properties ip_address $IP_ADDR

# Get XAP

DIR=/tmp/

# check only needed for local cloud 
if [ ! -d $DIR/xap ]; then
  mkdir $DIR/xap
  pushd $DIR/xap
  ctx logger info "getting xap from ${download_url}"
  wget -N ${download_url}

  unzip *.zip
  rm *.zip
  popd

  GSDIR=`ls -d $DIR/xap/gigaspaces*premium*`
  echo $GSDIR > /tmp/gsdir

  ctx logger info "GSDIR=$GSDIR" 
  ctx logger info "license_key=${license_key}"

  # Update license
  if [ -n "$license_key" ]; then
    AS='s!\(.*\)\(<licensekey>\)\(.*\)\(<\/licensekey>\)\(.*\)!\1\2'$license_key'\4\5!'
    sed -i -e "$AS" $GSDIR/gslicense.xml
    ctx logger info "Updated license key"
  fi


  # unzip scripts
  pushd $GSDIR/bin
  unzip advanced_scripts.zip	
  popd

  # add dynamic nat mapper (needed for gateway)

  ctx download-resource "xap-scripts/nat-mapper.jar" "@{\"target_path\": \"$GSDIR/lib/platform/ext/nat-mapper.jar\"}"


else
  if [ ! -d /tmp/gsdir ]; then
      GSDIR=`ls -d $DIR/xap/gigaspaces*premium*`
      echo $GSDIR > /tmp/gsdir
      ctx download-resource "xap-scripts/nat-mapper.jar" "@{\"target_path\": \"$GSDIR/lib/platform/ext/nat-mapper.jar\"}"
  fi
fi