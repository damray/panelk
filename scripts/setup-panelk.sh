#!/bin/bash

set -euo pipefail

user=paloalto

es_url=http://elastic:${ELASTIC_PASSWORD}@elasticsearch:9200
kb_url=http://elastic:${ELASTIC_PASSWORD}@kibana:5601
# Wait for Elasticsearch to start up before doing anything.
until curl -s $es_url -o /dev/null; do
    sleep 1
done
until curl -s $kb_url -o /dev/null; do
    sleep 1
done
# create user 
#until curl -s -H 'Content-Type:application/json' \
#     -XPOST $es_url/_security/user/${user} \
#     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
#do
# Set the password for the elastic user.
#until curl -s -H 'Content-Type:application/json' \
#     -XPOST $es_url/_security/user/${user}/_password \
#     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
#do
#    sleep 2
#    echo Retrying1...
#done

until curl \
     -H 'kbn-xsrf:true' \
     -XPOST $kb_url/api/saved_objects/_import \
     --form file=@/usr/share/kibana/config/object1.ndjson
do
    sleep 2
    echo Retrying2...
done

until curl \
     -H 'kbn-xsrf:true' \
     -XPOST $kb_url/api/saved_objects/_import \
     --form file=@/usr/share/kibana/config/object2.ndjson
do
    sleep 2
    echo Retrying3...
done