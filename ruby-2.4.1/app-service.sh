#!/bin/bash -e
cd /$_USER
sleep 1
exec 2>&1 /sbin/setuser nobody \
  ./app.sh
  
