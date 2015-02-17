#!/bin/bash

GRID_NAME=$1

XAPDIR=`cat /tmp/gsdir`  # left by install script
interfacename=$(ctx node properties interfacename)
IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
export NIC_ADDR=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

ctx logger info "deploying space, locators=$LOOKUPLOCATORS"
ctx logger info "space name, $GRID_NAME"
ctx logger info "schema, $SCHEMA"
ctx logger info "xap dir, $XAPDIR"

$XAPDIR/bin/gs.sh undeploy ${GRID_NAME}
