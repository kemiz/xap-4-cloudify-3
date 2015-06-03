#!/bin/bash
interfacename=$(ctx node properties interfacename)
IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
export NIC_ADDR=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

XAPDIR=`cat /tmp/gsdir`  # left by install script

cfy logger info "shutting down with locators=${LOOKUPLOCATORS} XAPDIR=$XAPDIR"
echo 1 | $XAPDIR/bin/gs.sh gsa shutdown
