#!/bin/bash

VERSION=0.1.0

PROG=$(basename $0)

function usage { 
    echo "Usage: $PROG [command]" 2>&1
    echo "$PROG - A quick bash script for stopping jackd, a2jmidid, and QjackCTL"
    echo "  -h	    Show help about command line options"
    echo 
    echo "  -u	    Uninstall $(basename $0)"
    echo
    echo "  -v	    Show version information"
    exit 1
}

function uninstall { 
    echo "Uninstalling $PROG"
    sudo rm /usr/local/bin/$PROG 
    exit 1
}

function version { 
    echo "$PROG: $VERSION"
    exit 1
}

while getopts ":huv" arg; do 
    case "${arg}" in 
	h) 
	    usage 
	    ;;
	u)
	    uninstall
	    ;;
	v)
	    version 
	    ;; 
    esac
done

#kill jackdbus if it is running
jackpid=$(pgrep jackdbus)
if [ "$jackpid" ]; then 
    echo "--- killing jackdbus"
    kill -9 $jackpid
fi 

#kill a2jmidi daemon if it is running
a2jpid=$(pgrep a2jmidid)
if [ "$a2jpid" ]; then 
    echo "--- killing a2jmidid"
    kill -9 $a2jpid
fi

#kill qjackctl if it is running
qjpid=$(pgrep qjackctl)
if [ "$qjpid" ]; then 
    echo "--- killing qjackctl"
    kill -9 $qjpid
fi
