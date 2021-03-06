#!/bin/bash

NRT_REPO=${TARGET_REPO:-https://github.com/icpac-igad/nrt-scripts.git}
NRT_DIR=$(basename $NRT_REPO .git)
LOG=${LOG:-udp://localhost}

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

# add line to enable sending email after cron job finishes
echo "MAILTO='eotenyo@icpac.net'" >>cron.tmp

find . -name "*.cron" | while read fname; do
  DIR=$(basename $(dirname $fname))
  cp -f ../.env $DIR
  chmod +x $DIR/start.sh
  if [ -z $CRONNOW ]; then
    CRON=$(cat $fname)
  else
    CRON="$(expr $(date +%M) + 2) $(date +%H) * * *"
  fi
  echo "$CRON cd $(pwd)/$DIR && LOG=$LOG ./start.sh >> /var/log/cron 2>&1" >>cron.tmp
done

crontab cron.tmp
crontab -l

echo "Finished"
