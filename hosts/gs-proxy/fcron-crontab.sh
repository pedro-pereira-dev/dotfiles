#!/bin/sh

# @runas(__USER__),runatreboot,runonce 30s until \
#   podman-compose -f $HOME/.config/podman/compose.yaml up -d --force-recreate --remove-orphans; \
#   do sleep 60; done

%daily,bootrun * 6-10 echo "[$(date +%a,\ %b\ %d\ %Y\ at\ %H:%M:%S)] update coisas" >>/tmp/teste-update.log
%daily,bootrun * 6-10 echo "[$(date +%a,\ %b\ %d\ %Y\ at\ %H:%M:%S)] pull coisas" >>/tmp/teste-pull.log

#@ 10s echo "[$(date +%a,\ %b\ %d\ %Y\ at\ %H:%M:%S)] teste user $(whoami)" >>/tmp/fcron.log
#@runas(__USER__) 7s echo "[$(date +%a,\ %b\ %d\ %Y\ at\ %H:%M:%S)] teste dentro do user $(whoami)" >>/tmp/fcron2.log

# @runas(__USER__) 1s echo "[$(date +%a,\ %b\ %d\ %Y\ at\ %H:%M:%S)] $(ping -c 1 gentoo.org)" >>/tmp/fcron2.log
# @runas(__USER__) 1s ping -c 1 gentoo.org >/dev/null 2>&1 && echo "[$(date +%a,\ %b\ %d\ %Y\ at\ %H:%M:%S)] ola" >>/tmp/fcron2.log
