#!/usr/bin/env bash

set -xe

cd "$(dirname "$0")"/..
mkdir -p /opt/screenshot_receiver
cp -r server/* /opt/screenshot_receiver
cp /opt/screenshot_receiver/screenshot_receiver.service /etc/systemd/system/
systemctl daemon-reload

if ! [ -f /opt/screenshot_receiver/env.conf ]
then
  PASSWORD=$(xkcdpass -d- -n4)
  cat > /opt/screenshot_receiver/env.conf << EOF
  SCREENSHOT_RECEIVER_USERNAME=admin
  SCREENSHOT_RECEIVER_PASSWORD=$PASSWORD
EOF
fi
