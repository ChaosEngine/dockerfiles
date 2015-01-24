#!/bin/bash
#adduser --disabled-password --gecos '' memsql
#adduser memsql sudo
#chsh -s /bin/bash memsql
#echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#su -m memsql -c /home/r/script.sh
#su -m memsql

su -m memsql -c '/var/lib/memsql/service start' && tail -F /var/lib/memsql/tracelogs/memsql.log
