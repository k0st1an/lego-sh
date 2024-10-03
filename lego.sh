#!/bin/bash

set -e

LEGOSH_DIR=${LEGOSH_DIR:-~/.legosh}
LEGOSH_ENV_FILE=$LEGOSH_DIR/env
LEGOSH_RENEW_DOMAINS_FILE=$LEGOSH_DIR/renew_cert.list
LEGOSH_NO_HOOK=${LEGOSH_NO_HOOK:-false}
ARG_ACTION=$1
ARG_DOMAINS=$2

function usage() {
  echo "Usage: $(basename "$0") ..."
  echo "ACTION:"
  echo "  run domain[,domain...]      run lego to get certificate"
  echo "  renew [domain[,domain...]]  renew certificate"
  echo "  revoke domain[,domain...]   revoke certificate"
  echo "  help                        show this help"
  echo
  echo "Path to env file: $LEGOSH_ENV_FILE"
  echo "Renew certs: $LEGOSH_RENEW_DOMAINS_FILE"
  echo
  echo "Repository: https:/github.com/k0st1an/legosh"
  echo "License: BSD 3-Clause"
}

function star_work() {
  # shellcheck source=/dev/null
  source "$LEGOSH_ENV_FILE"
  if [[ ! -x $(which lego) ]]; then echo "lego is not installed"; exit 1; fi
  if [[ -z $ARG_ACTION ]]; then echo "action is not defined"; exit 1; fi
  if [[ ($ARG_ACTION = "revoke" || $ARG_ACTION = "run") && -z $ARG_DOMAINS ]]; then echo "domain is not defined"; exit 1; fi
}

function domain_list() {
  echo "-d $1" | sed 's/\,/\ -d\ /g'
}

function hook() {
  if [[ $ARG_ACTION = "run" && -n $LEGOSH_RUN_HOOK && $LEGOSH_NO_HOOK = false ]]; then
    echo "--run-hook $LEGOSH_RUN_HOOK"
  elif [[ $ARG_ACTION = "renew" && -n $LEGOSH_RENEW_HOOK && $LEGOSH_NO_HOOK = false ]]; then
    echo "--renew-hook $LEGOSH_RENEW_HOOK"
  else
    echo ""
  fi
}

function processing() {
  echo "===================================="
  echo "Processing: $1"
  echo "===================================="
}

function run() {
  processing "$ARG_DOMAINS"
  lego --accept-tos --email "$LEGOSH_EMAIL" --dns $LEGOSH_DNS_PROVIDER $(domain_list "$ARG_DOMAINS") run $(hook)
  exit
}

function renew() {
  if [[ -n $ARG_DOMAINS ]]; then
    for DOMAIN in $(echo "$ARG_DOMAINS" | tr ',' '\n'); do
      processing "$DOMAIN"
      lego --email "$LEGOSH_EMAIL" --dns "$LEGOSH_DNS_PROVIDER" -d $DOMAIN renew $(hook)
    done
  elif [[ -r $LEGOSH_RENEW_DOMAINS_FILE ]]; then
    while IFS= read -r DOMAIN || [[ -n "$DOMAIN" ]]; do
      processing "$DOMAIN"
      lego --email "$LEGOSH_EMAIL" --dns "$LEGOSH_DNS_PROVIDER" $"$DOMAIN" renew $(hook)
    done < "$LEGOSH_RENEW_DOMAINS_FILE"
  else
    echo "domain is not defined" && exit 1
  fi
  exit
}

function revoke() {
  for DOMAIN in $(echo "$ARG_DOMAINS" | tr ',' '\n'); do
    processing "$DOMAIN"
    lego --email "$LEGOSH_EMAIL" -d "$DOMAIN" revoke
  done
  exit
}

case "$ARG_ACTION" in
  run | renew | revoke ) star_work; $ARG_ACTION;;
  * | help ) usage; exit;;
esac
