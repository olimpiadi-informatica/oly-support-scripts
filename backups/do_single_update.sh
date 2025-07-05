#!/bin/bash -e                                                                                            

echo "Syncing $1"
mkdir -p "$1"
rsync -e "ssh -o StrictHostKeyChecking=no" -aP --inplace --max-size=1M --exclude="/.*" --exclude "pwndbg/" root@"$1":/home/olympiads/ "$1/" || true
