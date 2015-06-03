#!/bin/bash
set -x
space_name=$(ctx node properties space_name)
gsc_cnt=$(ctx node properties gsc_cnt)
zones=$(ctx node properties zones)
GSC_JAVA_OPTIONS=$(ctx node properties GSC_JAVA_OPTIONS)
lrmi_comm_min_port=$(ctx node properties lrmi_comm_min_port)
lrmi_comm_max_port=$(ctx node properties lrmi_comm_max_port)

ctx download-resource xap-scripts/startgsc.groovy '@{"target_path": "/tmp/startgsc.groovy"}'

#sudo ulimit -n 32000
#sudo ulimit -u 32000

XAPDIR=`cat /tmp/gsdir`  # left by install script

# Update IP
interfacename=$(ctx node properties interfacename)
IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export NIC_ADDR=${IP_ADDR}
ctx logger info "About to post IP address ${IP_ADDR}"

ctx instance runtime_properties "ip_address" ${IP_ADDR}

export LOOKUPGROUPS=
export GSA_JAVA_OPTIONS
export LUS_JAVA_OPTIONS
export GSM_JAVA_OPTIONS
export GSC_JAVA_OPTIONS

LOOKUPLOCATORS=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
fi
export LOOKUPLOCATORS
ctx logger info "LOOKUPLOCATORS: ${LOOKUPLOCATORS}"
# Write empty NAT mapping file (required by mapper)
echo > /tmp/network_mapping.config

PS=`ps -eaf|grep -v grep|grep GSA`

if [ -n "${zones}" ]; then
	ZONES=$zones
else
	ZONES="${space_name}-gw"
fi
export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.network-mapping-file=/tmp/network_mapping.config -Dcom.gs.transport_protocol.lrmi.network-mapper=org.openspaces.repl.natmapper.ReplNatMapper"
export EXT_JAVA_OPTIONS="${EXT_JAVA_OPTIONS} -Dcom.gs.zones=${ZONES}"
#export GSC_JAVA_OPTIONS="$GSC_JAVA_OPTIONS -Dcom.gs.transport_protocol.lrmi.bind-port=${commport}"


GROOVY=$XAPDIR/tools/groovy/bin/groovy

if [ "$PS" = "" ]; then  #no gsa running already
	export EXT_JAVA_OPTIONS="${EXT_JAVA_OPTIONS}  -Dcom.gs.transport_protocol.lrmi.bind-port=$lrmi_comm_min_port-$lrmi_comm_max_port -Dcom.gigaspaces.start.httpPort=7104 -Dcom.gigaspaces.system.registryPort=7102"

	ctx logger info "NO GSA IS RUNNING!"

	ctx logger info "running gs-agent.sh from $CLOUDIFY_NODE_ID"

	nohup $XAPDIR/bin/gs-agent.sh gsa.global.lus=0 gsa.lus=0 gsa.global.gsm=0 gsa.gsm 0 gsa.gsc=1 >/tmp/xap.nohup.out 2>&1 &
	sleep 10

else 
	ctx logger info "THERE IS A RUNNUNG GSA!"

	ctx logger info "GSA already running"

	ctx logger info "calling:  $GROOVY /tmp/startgsc.groovy ${interfacename} ${gsc_cnt} \"$GSC_JAVA_OPTIONS $EXT_JAVA_OPTIONS\""

	$GROOVY /tmp/startgsc.groovy ${interfacename} ${gsc_cnt} "$GSC_JAVA_OPTIONS $EXT_JAVA_OPTIONS" > "/tmp/startgsc_gateway$(date).log"

	ctx logger info "called startgsc"

fi