#!/bin/bash

VERSION=0.1.0

function usage {
    echo "Usage: $(basename $0) [-drnpvh]" 2>&1
    echo "start_jack - A quick bash script for starting, stopping, and configuring JACK"
    echo "  -d	    Specify the audio device for the JACK server to use"
    echo "  -r	    Set the sample rate for the server"
    echo "  -n	    Set the number of periods for JACK (2 for PCI. 3 for USB)"
    echo "  -p	    Set the number of samples per period"
    echo "  -h	    Show help about command line options"
    echo "  -u	    Uninstall start_jack"
    echo "  -v	    Show version information"
    exit 1
}

function uninstall { 
    echo "Uninstalling $(basename $0)"
    sudo rm /usr/local/bin/start_jack
    exit 1
}

function version { 
    echo "$(basename $0): $VERSION"
    exit 1
}

DEVICE=PCH
RATE=48000
NPERIODS=2
PERIOD=128

options=":uvhdrnp"

while getopts ${options} arg; do 
    case "${arg}" in 
	d) 
	    DEVICE="${OPTARG}"
	    ;;
	r)
	    RATE="${OPTARG}"
	    ;; 
	n) 
	    NPERIODS="${OPTARG}"
	    ;; 
	p) 
	    PERIOD="${OPTARG}"
	    ;;
	v) 
	    version
	    ;; 
	h) 
	    usage
	    ;; 
	u)
	    uninstall
	    ;;
	?) 
	    echo "Invalid option: -${OPTARG}."
	    echo 
	    echo usage
	    ;;
    esac
done

#reset pulse audio to default io
pacmd "set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo"
pacmd "set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo"

echo "Resetting pulse audio"

sleep 1

#kill jackdbus if it is running
jackpid=$(pgrep jackdbus)
if [ "$jackpid" ]; then 
    echo "Killing jackdbus"
    kill -9 $jackpid
fi 

#kill a2jmidi daemon if it is running
a2jpid=$(pgrep a2jmidid)
if [ "$a2jpid" ]; then 
    echo "Killing a2jmidid"
    kill -9 $a2jpid
fi

#start jack
jack_control start
jack_control ds alsa
jack_control dps device hw:$DEVICE
jack_control dps rate $RATE 
jack_control dps nperiods $NPERIODS
jack_control dps period $PERIOD 

sleep 1 

#start a2j midi
a2j_control --ehw
a2j_control --start

sleep 1 

#set the pulse audio sink
pacmd "set-default-sink jack_out"
pacmd "set-default-source jack_in"

#open qjackctl 
echo "Opening qjackctl"
qjackctl -s &.
