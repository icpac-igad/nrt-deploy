#!/bin/bash

NRT_REPO=${TARGET_REPO:-https://github.com/icpac-igad/nrt-scripts.git}
NRT_DIR=$(basename $NRT_REPO .git)
LOG=udp://logs2.papertrailapp.com:24988

# fetch repo
echo "pulling repository"
if [ -d "$NRT_DIR" ]; then
    cd $NRT_DIR
    git pull origin main
else
    git clone $NRT_REPO
    cd $NRT_DIR
fi

# set up crontab
echo "Creating cronfile"
rm -f crontab
find . -name "*.cron" | while read fname; do
    DIR=$(basename $(dirname $fname))
    cp -f ../.env $DIR
    chmod +x $DIR/start.sh
    mkdir -p $DIR/data
    if [ -z $CRONNOW ]
    then
        CRON=$(cat $fname)
    else
        CRON="$(expr $(date +%M) + 2) $(date +%H) * * *"
    fi
    echo "$CRON cd $(pwd)/$DIR && LOG=$LOG ./start.sh >> /var/log/cron 2>&1" >> cron.tmp
done

crontab cron.tmp
crontab -l

echo "Finished"