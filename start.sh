#!/bin/bash

max_concurrent=${MAX_CONCURRENT:-3}
max_loop=${MAX_LOOP:-3}
tsp -S $max_concurrent

CONF="/conf"

SCRAPY_GITURL_DEFAULT=${SCRAPY_GITURL_DEFAULT:-"https://www.example.com/sample.git"}
SCRAPY_SPIDER_DEFAULT=${SCRAPY_SPIDER_DEFAULT:-"sample"}
SCRAPY_ENVS_DEFAULT=${SCRAPY_ENVS_DEFAULT:-"{}"}

while true
do
 for i in $(seq 1 ${max_loop}); do
  var_name_scrapy_giturl="scrapy_giturl_${i}"
  var_name_scrapy_spider="scrapy_spider_${i}"
  var_name_scrapy_envs="scrapy_envs_${i}"

  eval "scrapy_giturl_${i}=\"\${SCRAPY_GITURL_$i:-\$SCRAPY_GITURL_DEFAULT}\""
  eval "scrapy_spider_${i}=\"\${SCRAPY_SPIDER_$i:-\$SCRAPY_SPIDER_DEFAULT}\""
  eval "scrapy_envs_${i}=\"\${SCRAPY_ENVS_$i:-\$SCRAPY_ENVS_DEFAULT}\""

  if [ `tsp -l | grep -E queued\|running | wc -l` -lt 10 ] ; then
   JOBID=`tsp ./scrapy.sh "${CONF}" "${!var_name_scrapy_giturl}" "${!var_name_scrapy_spider}" "${!var_name_scrapy_envs}"`
   echo "----- task-spooler job:${JOBID} details -----"
   tsp -i $JOBID
  else
   echo "task spooler queue is over 10"
  fi

 done
 
 sleep 300
done
