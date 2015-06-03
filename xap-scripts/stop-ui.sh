#!/bin/bash

if [ -f /tmp/webui.pid ]; then
	PID=`cat /tmp/webui.pid`
	ctx logger info "killing webui pid=$PID"
	kill $PID
else
	ctx logger error "no pid file found for webui"
	exit 1
fi

