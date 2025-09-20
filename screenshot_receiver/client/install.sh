#!/bin/bash

set -xe

cd "$(dirname "$0")"

cp screenshotter.sh /usr/local/bin
chmod +x /usr/local/bin/screenshotter.sh
cp screenshotter.{service,timer} /etc/systemd/system
cp session-local.conf /etc/dbus-1/session-local.conf

sudo -u oii -g oii dbus-launch flatpak permission-set screenshot screenshot "" yes

systemctl daemon-reload
