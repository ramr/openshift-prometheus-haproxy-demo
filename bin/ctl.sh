#!/bin/bash

PROMBIN="/bin/prometheus"
CFG="/srv/prometheus/config"


function _generate() {
  if [ -f "${CFG}" ]; then
    echo "  - Config file ${CFG} already exists."
    return;
  fi

  local host=${HAPROXY_EXPORTER_HOST:-"10.0.2.15"}
  local port=${HAPROXY_EXPORTER_PORT:-"9101"}

  echo "
global:
  scrape_interval: "15s"  #  "60s"
  scrape_timeout: "10s"
  external_labels:
    source: openshift-origin-prometheus

  scrape_configs:
    - job_name:  "origin-router-haproxy"
      target_groups:
        -targets:
          - "${host}:${port}"
" > "${CFG}"

  echo "  - Generated config file: ${CFG}"

}  #  End of function  _generate.


function _usage() {
  [ -n "$1" ] && echo "$1"

  echo  "$0 [ start | stop | status | help ]"

}  #  End of function  _usage.


function start() {
  [ -f "${CFG}" ] || _generate
  
  echo "  - Starting Prometheus server with config ${CFG} ... "
  "${PROMBIN}" -c "${CFG}"

}  #  End of function  start.


function stop() {
  echo "  - Stopping Prometheus server ... "

  pkill "${PROMBIN}"

  echo "  - Stopped Prometheus server. "

}  #  End of function  stop.


function status() {
  if pgrep -f "${PROMBIN}" > /dev/null; then
    echo "  - Prometheus server is running $(pgrep -f "${PROMBIN}") "
  else
    echo "  - Prometheus server is NOT running."
  fi

}  #  End of function  status.


#
#  main():
#
opt=${1:-"status"}
case "${opt}" in
  start)   start  ;;
  stop)    stop   ;;
  status)  status ;;
  *)  _usage "Unsupported option ${1}" && exit 1 ;;
esac
