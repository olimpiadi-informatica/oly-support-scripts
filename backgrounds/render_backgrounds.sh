#!/bin/bash

SEATING=$1

if [ -z "$SEATING" ]
then
  echo Usage: $0 SEATING_CSV
  exit 1
fi

typst compile --features bundle background.typ --format bundle --ppi 300 --input seating=$SEATING
