#!/bin/bash

# Defaults
LOGLEVEL=0
THRESHOLD=30
RETCODE=0
DOMAINS=(
example.com
)


# Command line options parsing
while getopts "vd:t:" opts; do
    case "$opts" in
        "v") LOGLEVEL=$(( LOGLEVEL+1 )) ;;
        "d") DOMAINS=("$OPTARG") ;;
        "t") THRESHOLD=$OPTARG ;;
    esac
done

function msg {
    [ -n "$1" ] && echo $*
}

function alert {
    msg "[!] $*"
}

function error {
    msg "[x] $*"
    exit 1
}

function info {
    [ $LOGLEVEL -ge 1 ] && msg "[i] $*"
}

function debug {
    [ $LOGLEVEL -ge 2 ] && msg "[*] $*"
}

function exists {
    out=$(curl -sS https://$1 2>&1)
    ret=$?
    if [ $ret -gt 0 ]; then
        debug "curl returned: $out"
        debug "curl exited with code $ret"
    fi
    return $ret
}

function getsecs {
    date="$*"
    case `uname -s` in
        Darwin) 
            if ! command -v gdate > /dev/null; then
                error "please install coreutils for the gdate (gnu date) utility!"
            fi
            secs=$(gdate -d "`echo $date`" '+%s') ;;
        default)
            secs=$(date -d "`echo $date`" '+%s') ;;
    esac
    echo $secs
}

info "loglevel at $LOGLEVEL"
info "expiration threshold at $THRESHOLD"

for domain in ${DOMAINS[*]}; do 
    exists $domain || continue
    enddate=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
    debug "end date: $enddate"
    endsecs=$(getsecs $enddate)
    debug "end date in seconds: $endsecs"
    seconds_left=$(( $endsecs - `date '+%s'` ))
    debug "seconds left until expiry: $seconds_left"
    days_left=$(( $seconds_left / 86400 ))
    debug "days left until expiry: $days_left"
    if [ $days_left -le $THRESHOLD ]; then
        alert "$domain is about to expire in $days_left days!!!"
        RETCODE=$(( RETCODE+1))
    else
        info "$domain has $days_left days left"
    fi
done

exit $RETCODE
