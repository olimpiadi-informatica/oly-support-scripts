#!/bin/bash -e                                                         

parallel -j32 ../do_single_update.sh < ~/contestants.hosts || true
git add -A
git commit -m "$(date)" --allow-empty
