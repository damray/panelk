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

# Wait for Elasticsearch to start up before doing anything.
until curl -s $es_url/ -o /dev/null; do
    sleep 1
done
until curl -s $kb_url -o /dev/null; do
    sleep 1
done

until curl -H 'Content-Type:application/json'\
     -XPUT $es_url/_template/traffic_mapping \
     -d @/usr/share/kibana/config/traffic_template_mapping.json
do
    sleep 2
    echo inject traffic template...
    sleep 2
done

until curl -H 'Content-Type:application/json'\
     -XPUT $es_url/_template/threat_mapping \
     -d @/usr/share/kibana/config/threat_template_mapping.json
do
    sleep 2
    echo inject threat template...
    sleep 2
done

until curl -H 'Content-Type:application/json'\
     -XPUT $es_url/_template/gp_mapping \
     -d @/usr/share/kibana/config/gp_template_mapping.json
do
    sleep 2
    echo inject gp template...
    sleep 2
done

until curl -H 'Content-Type:application/json'\
     -XPUT $es_url/_template/system_mapping \
     -d @/usr/share/kibana/config/system_template_mapping.json
do
    sleep 2
    echo inject system template...
    sleep 2
done

until curl \
     -H 'kbn-xsrf:true' \
     -H 'overwrite' \
     -XPOST $kb_url/api/saved_objects/_import?overwrite=true \
     --form file=@/usr/share/kibana/config/object1.ndjson
do
    sleep 2
    echo inject object...
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/_ilm/policy/gp-policy \
     -d '{ "policy": {"phases": {"delete": {"min_age": "30d","actions": {"delete": {}}}}}}'
do
    sleep 2
    echo create Index Lifecycle policy gp-policy...
    sleep 2
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/_ilm/policy/traffic-policy \
     -d '{ "policy": {"phases": {"delete": {"min_age": "30d","actions": {"delete": {}}}}}}'
do
    sleep 2
    echo create Index Lifecycle policy traffic-policy...
    sleep 2
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/_ilm/policy/threat-policy \
     -d '{ "policy": {"phases": {"delete": {"min_age": "30d","actions": {"delete": {}}}}}}'
do
    sleep 2
    echo create Index Lifecycle policy threat-policy...
    sleep 2
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/panos-gp
do
    sleep 2
    echo create Index panos-gp...
    sleep 2
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/panos-gp
do
    sleep 2
    echo create Index panos-gp...
    sleep 2
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/panos-traffic
do
    sleep 2
    echo create Index panos-traffic...
    sleep 2
done

until curl -H 'Content-Type: application/json'\
     -XPUT $es_url/panos-threat
do
    sleep 2
    echo create Index panos-threat...
    sleep 2
done

#never stop
tail -f /dev/null