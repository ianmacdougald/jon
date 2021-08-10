#!/bin/bash

if [ $1 == "uninstall" ] || [ $1 == "--uninstall" ] || [ $1 == "-u" ]; then 
    echo "Uninstalling start_jack"
    sudo rm /usr/local/bin/start_jack
    exit 
fi 

if [ $1 == "version" ] || [ $1 == "--version" ] || [ $1 == "-v" ]; then 
    echo "start_jack: 0.1.0"
    exit
fi

if [ $1 == "help" ] || [ $1 == "--help" ] || [ $1 == "-h" ]; then 
    echo "Usage: start_jack [options] [command-and-args]"
    echo ""
    echo "start_jack - A quick bash script for starting, stopping, and configuring JACK"
    echo ""
    echo "Options:"
    echo ""
    echo "--device
	Specify the audio device for the JACK server to use"
    echo "--rate
	Set the sample rate for the server"
    echo "--nperiods
	Set the number of periods for JACK (2 for PCI. 3 for USB)"
    echo ""
    echo "--period
	Set the number of samples per period"
    echo ""
    echo "-h, --help
	Show help about command line options"
    echo ""
    echo "-u, --uninstall
	Uninstall start_jack"
    echo "-v, --version 
	Show version information"
    exit 
fi 

#set up parameters
device=${device:-PCH}
rate=${rate:-48000}
nperiods=${nperiods:-2}
period=${period:-64}

#assign customized parameters
while [ $# -gt 0 ]; do 
    if [[ $1 == *"--"* ]]; then 
	param="${1/--/}"
	declare $param="$2"
    fi

    shift 
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
jack_control dps device hw:$device
jack_control dps rate $rate 
jack_control dps nperiods $nperiods
jack_control dps period $period 

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

#open patchage
echo "Opening patchage"
patchage & > /dev/null
