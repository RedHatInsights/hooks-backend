#!/bin/sh

set -e

rm -f /app/tmp/pids/server.pid
nginx -c /app/docker/endpoint/site.conf
echo "Running nginx with config:"
cat /app/docker/endpoint/site.conf
exec "$@"
