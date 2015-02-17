#!/bin/bash

export LOOKUPGROUPS=
export GSA_JAVA_OPTIONS=$(ctx -node properties GSA_JAVA_OPTIONS)
export LUS_JAVA_OPTIONS=$(ctx node properties LUS_JAVA_OPTIONS)
export GSM_JAVA_OPTIONS=$(ctx node properties GSM_JAVA_OPTIONS)
export GSC_JAVA_OPTIONS=$(ctx node properties GSC_JAVA_OPTIONS)
gsm_cnt=$(ctx -j node properties gsm_cnt)
global_gsm_cnt=$(ctx -j node properties global_gsm_cnt)
lus_cnt=$(ctx -j node properties lus_cnt)
gsc_cnt=$(ctx -j node properties gsc_cnt)
global_lus_cnt=$(ctx -j node properties global_lus_cnt)
lrmi_comm_min_port=$(ctx node properties lrmi_comm_min_port)
lrmi_comm_max_port=$(ctx node properties lrmi_comm_max_port)
zones=$(ctx node properties zones)
interfacename=$(ctx node properties interfacename)
ctx download-resource xap-scripts/startgsc.groovy '@{"target_path": "/tmp/startgsc.groovy"}'

sudo ulimit -n 32000
sudo ulimit -u 32000

XAPDIR=`cat /tmp/gsdir`  # left by install script

ctx logger info "gsm=$gsm_cnt gsc=$gsc_cnt lus=$lus_cnt"

ip=$(ctx instance runtime_properties ip_address)

IP_ADDR=$ip

LOOKUPLOCATORS=$IP_ADDR  #default to local
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		if [ "$line" != "$IP_ADDR" ]; then
			LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
		fi
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
fi
if [ "$lus_cnt" != 0 ]; then
	echo "${IP_ADDR}" >> /tmp/locators
	LOOKUPLOCATORS="${IP_ADDR},${LOOKUPLOCATORS}"
fi

export LOOKUPLOCATORS
export NIC_ADDR=${IP_ADDR}
export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.bind-port=$lrmi_comm_min_port-$lrmi_comm_max_port -Dcom.gigaspaces.start.httpPort=7104 -Dcom.gigaspaces.system.registryPort=7102"

export GSC_JAVA_OPTIONS="$GSC_JAVA_OPTIONS -Dcom.gs.zones=${zones}"

PS=`ps -eaf|grep -v grep|grep GSA`

if [ "$PS" = "" ]; then  #no gsa running already

	ctx logger info "running $XAPDIR/bin/gs-agent.sh gsa.global.lus $global_lus_cnt gsa.lus $lus_cnt gsa.global.gsm $global_gsm_cnt gsa.gsm $gsm_cnt gsa.gsc $gsc_cnt"

	nohup $XAPDIR/bin/gs-agent.sh gsa.global.lus $global_lus_cnt gsa.lus $lus_cnt gsa.global.gsm $global_gsm_cnt gsa.gsm $gsm_cnt gsa.gsc $gsc_cnt >/tmp/xap.nohup.out 2>&1 &

        sleep 10

else #running local cloud

	ctx logger info "running gs-agent.sh"

	if [ $gsm_cnt -gt 0 ]; then
		echo $gsm_cnt|$XAPDIR/bin/gs.sh gsa start-gsm
	fi
	if [ $lus_cnt -gt 0 ]; then
		echo $lus_cnt|$XAPDIR/bin/gs.sh gsa start-lus
	fi
	if [ $gsc_cnt -gt 0 ]; then
		GROOVY=$XAPDIR/tools/groovy/bin/groovy
		ctx logger info "calling:  $GROOVY /tmp/startgsc.groovy ${interfacename} ${gsc_cnt} \"$GSC_JAVA_OPTIONS $EXT_JAVA_OPTIONS\""
		$GROOVY /tmp/startgsc.groovy ${interfacename} ${gsc_cnt} "$GSC_JAVA_OPTIONS $EXT_JAVA_OPTIONS" > "/tmp/startgsc_xap$(date).log"
	fi

fi
