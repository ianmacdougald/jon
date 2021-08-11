#!/bin/bash

VERSION=0.1.0

PROG=$(basename $0)

if (! command -v jack_control &> /dev/null) || (! command -v a2jmidid &> /dev/null) || (! command -v qjackctl &> /dev/null); then 
    echo "Dependencies not installed."
    echo "Run the following:"
    echo
    echo "sudo apt install jackd2 a2jmidid qjackctl"
    exit 1
fi 

function usage {
    echo "Usage: $PROG [command] [command] ..." 2>&1
    echo "$PROG - A quick bash script for starting JACK, a2jmidid, and QjackCtl"
    echo "  -d <param>	    Specify the audio device for the JACK server to use"
    echo 
    echo "  -h		    Show help about command line options"
    echo
    echo "  -k		    Kill jackd, a2jmidid, and QjackCtl"
    echo
    echo "  -n <param>	    Set the number of periods for JACK (2 for PCI. 3 for USB)"
    echo
    echo "  -p <param>	    Set the number of samples per period"
    echo
    echo "  -r <param>	    Set the sample rate for the server"
    echo 
    echo "  -u		    Uninstall $PROG"
    echo 
    echo "  -v		    Show version information"
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

function kill_jack { 
    jof 
    exit 1
}

DEVICE="PCH"
RATE=48000
NPERIODS=2
PERIOD=128

while getopts ":d:r:n:p:vhuk" arg; do 
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
	k)
	    kill_jack 
	    ;;
	?) 
	    echo "Invalid option: -${OPTARG}."
	    echo 
	    usage
	    ;;
    esac
done

#kill jack, a2jmidid, and qjackctl 
jof

#reset pulse audio to default io
pacmd "set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo"
pacmd "set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo"

echo "--- resetting pulse audio"

sleep 1

#start jack
jack_control ds alsa
jack_control dps device hw:$DEVICE
jack_control dps capture hw:$DEVICE
jack_control dps playback hw:$DEVICE
jack_control dps rate $RATE 
jack_control dps nperiods $NPERIODS
jack_control dps period $PERIOD 
jack_control start &> /dev/null
echo "--- starting jackd"

#start a2j midi
a2j_control --ehw
a2j_control --start &> /dev/null
echo "--- starting a2jmidid"

sleep 1 

#set the pulse audio sink
pacmd "set-default-sink jack_out"
pacmd "set-default-source jack_in"

#open qjackctl 
echo "--- starting qjackctl"
qjackctl -s &
