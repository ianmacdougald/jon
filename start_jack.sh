#!/bin/bash

SESSION=$1

#reset pulse audio to default io
pacmd "set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo"
pacmd "set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo"

echo "Resetting pulse audio"

sleep 1.5

#kill jackdbus if it is running
jackpid=$(pgrep jackdbus)
if [ "$jackpid" ]; then 
    echo "Killing: jackdbus"
    kill -9 $jackpid
fi 

#kill a2jmidi daemon if it is running
a2jpid=$(pgrep a2jmidid)
if [ "$a2jpid" ]; then 
    echo "Killing: a2jmidid"
    kill -9 $a2jpid
fi

jack_control start
jack_control ds alsa
jack_control dps device hw:M12
jack_control dps rate 48000
jack_control dps nperiods 2
jack_control dps period 64
sleep 1 
a2j_control --ehw
a2j_control --start
sleep 1 
pacmd "set-default-sink jack_out"
pacmd "set-default-source jack_in"

if [[ $# -eq 0 ]] ; then 
    SESSION="basic_setup"
fi

echo "--- nsmd session -> $SESSION"
nsmd --load-session $SESSION
