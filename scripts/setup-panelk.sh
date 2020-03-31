#!/bin/bash

set -euo pipefail

user=paloalto

es_url=http://elastic:${ELASTIC_PASSWORD}@elasticsearch:9200
kb_url=http://elastic:${ELASTIC_PASSWORD}@kibana:5601

until curl -s -f http://elastic:${ELASTIC_PASSWORD}@elasticsearch:9200/_cat/health -o /dev/null ; do
    sleep 2 
done

until curl -s -f http://elastic:${ELASTIC_PASSWORD}@kibana:5601/status -o /dev/null ; do
    sleep 2 
done

# if [[ $$? == 52 ]]; then echo 0; else echo 1; fi


# Wait for Elasticsearch to start up before doing anything.
until curl -s $es_url/ -o /dev/null; do
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
     -XPUT $es_url/_template/traffic_mapping \
     --form file=@/usr/share/kibana/config/traffic_template_mapping.json
do
    sleep 2
    echo inject traffic template...
    sleep 2
done

until curl \
     -XPUT $es_url/_template/threat_mapping \
     --form file=@/usr/share/kibana/config/threat_template_mapping.json
do
    sleep 2
    echo inject threat template...
    sleep 2
done

until curl \
     -H 'kbn-xsrf:true' \
     -XPOST $kb_url/api/saved_objects/_import \
     --form file=@/usr/share/kibana/config/object1.ndjson
do
    sleep 2
    echo inject object...
done

until curl \
     -H 'kbn-xsrf:true' \
     -XPOST $kb_url/api/saved_objects/_import \
     --form file=@/usr/share/kibana/config/object2.ndjson
do
    sleep 2
    echo inject dashboard...
done