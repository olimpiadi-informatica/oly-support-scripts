#!/bin/bash

set -xe

# This needs a patched Gnome and should be integrated in arch-oly-install.

TMPDIR=$(mktemp -d)

cleanup() {
  rm -rf $TMPDIR
}

trap cleanup EXIT

cat > $TMPDIR/screen.py << EOF
#!/usr/bin/env python3

import dbus
from gi.repository import GLib
import dbus.mainloop.glib
import uuid

loop = None


def response_handler(response, result):
    global loop
    if response == 0:
        print(f'{result.get("uri")}'[7:])
    else:
        print("FAILED")
    GLib.MainLoop.quit(loop)


def main():
    global loop
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    my_name = bus.get_connection().get_unique_name()[1:].replace(".", "_")
    my_token = str(uuid.uuid4()).replace("-", "")
    response_path = f"/org/freedesktop/portal/desktop/request/{my_name}/{my_token}"
    bus.add_signal_receiver(
        response_handler,
        dbus_interface="org.freedesktop.portal.Request",
        path=response_path,
    )

    desktop = bus.get_object(
        "org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop")
    desktop.Screenshot("Screenshot", {
                       "handle_token": f"{my_token}"}, dbus_interface="org.freedesktop.portal.Screenshot")
    loop = GLib.MainLoop()
    loop.run()


if __name__ == "__main__":
    main()
EOF

chmod +x $TMPDIR/screen.py

IMG=$(sudo env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u oii)/bus $TMPDIR/screen.py)

U=$(whoami)

set -xe

sudo mv ${IMG} $TMPDIR/screen.png
sudo chown $U:$U $TMPDIR/screen.png
cjxl $TMPDIR/screen.png -d 1 $TMPDIR/screen.jxl
convert $TMPDIR/screen.png -resize 640x360 $TMPDIR/screen.avif
curl -i \
  -X POST -H "Content-Type: multipart/form-data" \
  -F "file=@$TMPDIR/screen.jxl" -F "preview=@$TMPDIR/screen.avif" \
  http://olympiads-server:2345/upload
