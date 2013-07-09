#! /bin/bash
#
# description: vbucketmigrator startup script
# processname: vbucketmigrator.sh
# config: /etc/sysconfig/vbucketmigrator
# location: /opt/zbase/bin/vbucketmigrator/vbucketmigrator.sh

USER=nobody
PIDFILE="/var/run/vbucketmigrator.pid"

# spit everything to syslog using logger
exec &> >(logger -t '[vbucketmigrator]' --)

tap_alive () {
    local tapname

    tapname="$1"

    tap_stats=$(nc localhost 11211 < <(echo 'stats tap') | sed 's/\x0D//g;')
    if grep -q "STAT eq_tapq:$tapname:connected" <<<"${tap_stats}"; then
        return 0
    else 
        return 1
    fi
}

# keep running vbucketmigrator continuously
while :; do
    if [[ -f /etc/sysconfig/vbucketmigrator ]];then 
    	. /etc/sysconfig/vbucketmigrator
    fi

    if [[ -n "$USER" ]];then
        su -s /bin/bash - $USER -c "/opt/zbase/bin/vbucketmigrator -N $TAPNAME -d $SLAVE  -r -h 127.0.0.1:11211 -b 0 -A -v $OPTIONS"
    else
        /opt/zbase/bin/vbucketmigrator -N $TAPNAME -d $SLAVE -r -h 127.0.0.1:11211 -b 0 -A -v $OPTIONS
    fi

    echo "vbucketmigrator exit"
    # process exited. check if tap is alive
    if ! tap_alive $TAPNAME; then
		# tap is not alive. Don't restart vbm
		echo "tap information not available for $SLAVE on this host. Exiting vbucketmigrator"
		break
    fi
    # sleep for some time before restarting
    sleep 5
    echo "Restarting vbucketmigrator"
done

# exit from loop. cleanup and exit
[[ -f "$PIDFILE" ]] && rm -f "$PIDFILE"
exit 0
