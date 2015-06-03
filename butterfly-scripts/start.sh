#!/bin/bash

function error_exit {
   ctx logger error "$2 : error code: $1"
   exit ${1}
}
port=$(ctx node properties port) || error_exit $? "Unable to set port from properties"
interfacename=$(ctx node properties interfacename)
lrmi_comm_min_port=$(ctx node properties lrmi_comm_min_port)
lrmi_comm_max_port=$(ctx node properties lrmi_comm_max_port)

IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
GSDIR=`cat /tmp/gsdir`
LOOKUPLOCATORS=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
fi

export LOOKUPLOCATORS
export NIC_ADDR=${IP_ADDR}
#export GS_GROOVY_HOME=$GSDIR/tools/groovy/
export LRMI_COMM_MIN_PORT=$lrmi_comm_min_port
export LRMI_COMM_MAX_PORT=$lrmi_comm_max_port

export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.bind-port=$LRMI_COMM_MIN_PORT-$LRMI_COMM_MAX_PORT -Dcom.gigaspaces.start.httpPort=7104 -Dcom.gigaspaces.system.registryPort=7102"


export GS_HOME=$GSDIR



UUID=asdfsd

source ~/.bashrc
source /tmp/virtenv_is/bin/activate

UUID=`uuidgen`

ctx logger info "launching butterfly server"
nohup python /tmp/demodl/butterfly/butterfly.server.py --host="0.0.0.0" --port="$port" --unsecure --prompt_login=false --wd="/tmp/demodl/XAP-Interactive-Tutorial-master" --load_script="/tmp/demodl/XAP-Interactive-Tutorial-master/start_tutorial.sh" >/tmp/demodl.nohup.out $UUID 2>&1 &
sleep 1
ctx logger info "launched butterfly server"
deactivate
ctx logger info "deactivated"

echo $! > /tmp/butterfly.pid

ctx logger info "butterfly started"
