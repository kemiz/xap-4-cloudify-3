#!/bin/sh

if [ -f /tmp/butterfly.pid ]; then
	PID=`cat /tmp/butterfly.pid`
	ctx logger info "killing butterfly pid=$PID"
	kill $PID
else
	ctx logger error "no pid file found for butterfly"
	exit 1
fi

