#!/bin/sh

haproxy $@ -D -p /var/run/haproxy.pid &

# Check if config changed
while inotifywait -e create,delete,modify,move -q /etc/haproxy/; do haproxy $1 -D -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid); done