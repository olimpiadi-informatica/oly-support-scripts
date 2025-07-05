#!/bin/bash

cp backup_homes* /etc/systemd/system
systemctl daemon-reload

mkdir -p /opt/home-backups/backups
git init /opt/home-backups/backups

pushd /opt/home-backups/backups
git config user.email "root@olympiads-server"
git config user.name "Automated Backups"
popd

cp do_single_update.sh update.sh /opt/home-backups

systemctl enable --now backup_homes.timer
