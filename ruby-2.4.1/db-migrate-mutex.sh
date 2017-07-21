#!/bin/bash
set -x
cd /$_USER && \
if bundle show rails_migrate_mutex; then
  /sbin/setuser $_USER bundle exec rake db:migrate:mutex
fi
