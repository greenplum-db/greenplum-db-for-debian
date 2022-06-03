#!/bin/sh
autoreconf -f -i
cd gpAux/extensions/pgbouncer/source
./lib/mk/std-autogen.sh ./lib
