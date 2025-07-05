#!/bin/bash

HOSTS=$1
SEATING=$2
LOGO=$3

if [ -z "$LOGO" ]
then
  echo Usage: $0 HOSTS_FILE SEATING_CSV LOGO
  exit 1
fi

for i in $(cat $HOSTS | cut -f 2 -d ' ')
do
  mkdir -p /opt/backgrounds/$i
  typst compile background.typ \
    /opt/backgrounds/$i/background.png \
    --ppi 300 --root / --input seating=$SEATING --input logo=$LOGO \
    --input hostname=$i &
done
wait
