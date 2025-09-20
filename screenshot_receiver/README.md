## Setup

You need to install `python-flask`, `uwsgi` and `uwsgi-plugin-python` on the
server.

The uwsgi app exposes `/upload` with no authentication, and everything else
with.

There are two `install.sh` scripts in the `server` and `client` folder. The
server install script also generates a basic auth password.

Note that the client setup is not complete, as the packages need to be patched
manually.
