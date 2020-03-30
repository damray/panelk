#!/bin/bash

set -euo pipefail

es_url=http://elastic:${ELASTIC_PASSWORD}@192.168.45.100:9200
kb_url=http://elastic:${ELASTIC_PASSWORD}@192.168.45.100:5601
# Wait for Elasticsearch to start up before doing anything.
until curl -s $es_url -o /dev/null; do
    sleep 1
done

# Set the password for the logstash_system user.
# REF: https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords
until curl -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_xpack/security/user/logstash_system/_password \
     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo Retrying1...
done

until curl \
     -H 'kbn-xsrf:true' \
     -XPOST $kb_url/api/saved_objects/_import \
     --form file=@/usr/share/kibana/config/object1.ndjson
do
    sleep 2
    echo Retrying2...
done