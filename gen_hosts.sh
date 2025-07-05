#!/bin/bash

PREFIX=$1
LAST_LETTER=$2
LAST_COLUMN=$3

if [ -z "$LAST_COLUMN" ]
then
  echo Usage: $0 PREFIX LAST_LETTER LAST_COLUMN
  exit 1
fi

chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

NUM_LETTERS=$(($(ord $LAST_LETTER)-$(ord a)+1))

for ((LETTER = 0; LETTER < NUM_LETTERS; LETTER++))
do
  for ((COL = 1; COL <= LAST_COLUMN; COL++))
  do
    echo 10.1.$((LETTER+1)).$COL $PREFIX-$(chr $((LETTER+$(ord a))))$(printf %02d $COL)
  done
done

