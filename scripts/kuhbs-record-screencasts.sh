#!/bin/bash
#
# Needs ffmpeg:
# 1) Download ffmpeg static binary from https://github.com/eugeneware/ffmpeg-static/releases
# 2) unpack: `gunzip ffmpeg-linux-x64.gz`
# 3) copy to dom0: qvm-run --pass-io disp0123 'cat ffmpeg-linux' > ffmpeg
# 4) record: ./ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0+0,0 rec.mp4


set -e


# Execute with ./script.sh "$PS1"
#
PS1=$1

if [[ "$PS1" == "" ]]; then
    echo "run like this: ./$0 \"\$PS1\""
    exit 1
fi


commands="kuhbs show firefox
kuhbs create firefox
kuhbs upgrade firefox
kuhbs remove firefox
kuhbs ls"

#qvm-start app-firefox
#kuhbs dump app-firefox"

#kuhbs backup firefox
#kuhbs backup-all
#kuhbs restore firefox

#kuhbs upgrade-all

#kuhbs terminal app-firefox
#kuhbs terminal app-firefox root



# Start screen recording
echo "STARTING RECORDING IN 2 SECONDS"
sleep 2
reset

/home/user/ffmpeg -y -loglevel panic -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0+0,0 /home/user/kuhbs-demo.mp4 &

# Iterate commands
echo -e "$commands" | while read command; do

    # Run command while printing PS1 so it looks real ;)
    clear
    printf "${PS1@P}"
    sleep 1
    printf "$command"
    sleep 2
    printf "\n"
    $command
    printf "${PS1@P}"
    sleep 5

done

# Stop recording
killall ffmpeg
sleep 0.5
echo "STOPPED RECORDING"
