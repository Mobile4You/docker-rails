#!/usr/bin/env bash
CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"

exec docker build -t m4ucorp/ruby:2.4.1 "$CMD_BASE"
exec docker push m4ucorp/ruby:2.4.1
