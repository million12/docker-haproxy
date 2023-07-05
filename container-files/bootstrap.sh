#!/bin/bash

set -u

# User params
HAPROXY_CONFIG=${HAPROXY_CONFIG:="/etc/haproxy/haproxy.cfg"}
HAPROXY_ADDITIONAL_CONFIG=${HAPROXY_ADDITIONAL_CONFIG:=""}
HAPROXY_PORTS=${HAPROXY_PORTS:="80,443"}
HAPROXY_PRE_RESTART_CMD=${HAPROXY_PRE_RESTART_CMD:=""}
HAPROXY_POST_RESTART_CMD=${HAPROXY_POST_RESTART_CMD:=""}
HAPROXY_USER_PARAMS=$@

# Internal params
HAPROXY_CMD="/usr/local/sbin/haproxy -f ${HAPROXY_CONFIG} -W ${HAPROXY_USER_PARAMS}"
HAPROXY_CHECK_CONFIG_CMD="/usr/local/sbin/haproxy -f ${HAPROXY_CONFIG} -c"

#######################################
# Echo/log function
# Arguments:
#   String: value to log
#######################################
log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

#######################################
# Dump current $HAPROXY_CONFIG
#######################################
print_config() {
  log "Current HAProxy config $HAPROXY_CONFIG:"
  printf '=%.0s' {1..100} && echo
  cat $HAPROXY_CONFIG
  printf '=%.0s' {1..100} && echo
}

# Launch HAProxy.
# In the default attached haproxy.cfg `web.server` host is used for back-end nodes.
# If that host doesn't exist in /etc/hosts, create it and point to localhost,
# so HAProxy can start with the default haproxy.cfg config without throwing errors.
grep --silent -e "web.server" /etc/hosts || echo "127.0.0.1 web.server" >> /etc/hosts

log $HAPROXY_CMD && print_config
$HAPROXY_CHECK_CONFIG_CMD
$HAPROXY_CMD &

HAPROXY_PID=$!

# Exit immediately in case of any errors or when we have interactive terminal
if [[ $? != 0 ]] || test -t 0; then exit $?; fi
log "HAProxy started with $HAPROXY_CONFIG config, pid $HAPROXY_PID." && log

# Check if config has changed
# Note: also monitor /etc/hosts where the new back-end hosts might be provided.
while inotifywait -q -e create,delete,modify,attrib /etc/hosts $HAPROXY_CONFIG $HAPROXY_ADDITIONAL_CONFIG; do
  log "Restarting HAProxy due to config changes..." && print_config
  $HAPROXY_CHECK_CONFIG_CMD
  log "Executing pre-restart hook..."
  $HAPROXY_PRE_RESTART_CMD
  log "Restarting haproxy..."
  $HAPROXY_CMD -sf $HAPROXY_PID &
  HAPROXY_PID=$!
  log "Got new PID: $HAPROXY_PID"
  log "Executing post-restart hook..."
  $HAPROXY_POST_RESTART_CMD
  log "HAProxy restarted, pid $HAPROXY_PID." && log
done
