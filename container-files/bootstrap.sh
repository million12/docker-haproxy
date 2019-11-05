#!/bin/sh

set -u

# User params
HAPROXY_CONFIG=${HAPROXY_CONFIG:="/etc/haproxy/haproxy.cfg"}
HAPROXY_ADDITIONAL_CONFIG=${HAPROXY_ADDITIONAL_CONFIG:=""}
HAPROXY_PORTS=${HAPROXY_PORTS:="80,443"}
HAPROXY_PRE_RESTART_CMD=${HAPROXY_PRE_RESTART_CMD:=""}
HAPROXY_POST_RESTART_CMD=${HAPROXY_POST_RESTART_CMD:=""}
HAPROXY_USER_PARAMS=$@

# Internal params
HAPROXY_PID_FILE="/var/run/haproxy.pid"
HAPROXY_CMD="/usr/local/sbin/haproxy -f ${HAPROXY_CONFIG} ${HAPROXY_USER_PARAMS} -p ${HAPROXY_PID_FILE}"
HAPROXY_CHECK_CONFIG_CMD="/usr/local/sbin/haproxy -f ${HAPROXY_CONFIG} -c"

# Iptable commands
LIST_IPTABLES="iptables --list"
ENABLE_SYN_DROP="iptables -I INPUT -p tcp -m multiport --dport $HAPROXY_PORTS --syn -j DROP"
DISABLE_SYN_DROP="iptables -D INPUT -p tcp -m multiport --dport $HAPROXY_PORTS --syn -j DROP"


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

# Check iptables rules modification capabilities
$LIST_IPTABLES > /dev/null 2>&1
# Exit immidiately in case of any errors
if [[ $? != 0 ]]; then
    EXIT_CODE=$?;
    echo "Please enable NET_ADMIN capabilities by passing '--cap-add NET_ADMIN' parameter to docker run command";
    exit $EXIT_CODE;
fi

# Launch HAProxy.
# In the default attached haproxy.cfg `web.server` host is used for back-end nodes.
# If that host doesn't exist in /etc/hosts, create it and point to localhost,
# so HAProxy can start with the default haproxy.cfg config without throwing errors.
grep --silent -e "web.server" /etc/hosts || echo "127.0.0.1 web.server" >> /etc/hosts

log $HAPROXY_CMD && print_config
$HAPROXY_CHECK_CONFIG_CMD
$HAPROXY_CMD &
# Exit immidiately in case of any errors or when we have interactive terminal
if [[ $? != 0 ]] || test -t 0; then exit $?; fi
log "HAProxy started with $HAPROXY_CONFIG config, pid $(cat $HAPROXY_PID_FILE)." && log

# Check if config has changed
# Note: also monitor /etc/hosts where the new back-end hosts might be provided.
while inotifywait -q -e create,delete,modify,attrib /etc/hosts $HAPROXY_CONFIG $HAPROXY_ADDITIONAL_CONFIG; do
  if [ -f $HAPROXY_PID_FILE ]; then
    log "Restarting HAProxy due to config changes..." && print_config
    $HAPROXY_CHECK_CONFIG_CMD
    $ENABLE_SYN_DROP
    sleep 0.2
    log "Executing pre-restart hook..."
    $HAPROXY_PRE_RESTART_CMD
    log "Restarting haproxy..."
    $HAPROXY_CMD -sf $(cat $HAPROXY_PID_FILE)
    log "Executing post-restart hook..."
    $HAPROXY_POST_RESTART_CMD
    $DISABLE_SYN_DROP
    log "HAProxy restarted, pid $(cat $HAPROXY_PID_FILE)." && log
  else
    log "Error: no $HAPROXY_PID_FILE present, HAProxy exited."
    break
  fi
done
