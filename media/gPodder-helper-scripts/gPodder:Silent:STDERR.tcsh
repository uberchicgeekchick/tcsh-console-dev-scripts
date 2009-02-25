#!/bin/tcsh -f
( gpodder "${argv}" > /dev/tty ) >& /dev/null
