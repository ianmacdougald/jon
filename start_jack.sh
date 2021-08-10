#!/bin/bash

if [ $1 == "uninstall" ]; then 
    echo "Uninstalling start_jack"
    sudo rm /usr/local/bin/start_jack
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
