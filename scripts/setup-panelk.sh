#!/bin/bash

set -euo pipefail
es_url=http://${ELASTIC_USER}:${ELASTIC_PASSWORD}@es01:9200
kb_url=http://${ELASTIC_USER}:${ELASTIC_PASSWORD}@kibana:5601

# Wait for Elasticsearch to start up before doing anything.

until curl -s -f $es_url/_cat/health -o /dev/null ; do
    sleep 2 
done

until curl -s -f http://${ELASTIC_USER}:${ELASTIC_PASSWORD}@kibana:5601/status -o /dev/null ; do
    sleep 2 
done

# Push Template for the different Index
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

# Push Object and overwrite existing object in case of update
until curl \
     -H 'kbn-xsrf:true' \
     -H 'overwrite' \
     -XPOST $kb_url/api/saved_objects/_import?overwrite=true \
     --form file=@/usr/share/kibana/config/object1.ndjson
do
    sleep 2
    echo inject object...
done

# Create Index and Index lifecycle policy in ES to avoid indexing latency for the first log
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

# Never stop the container script in case of debugging
# tail -f /dev/null