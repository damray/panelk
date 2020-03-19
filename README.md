# PAN-OS Elk integration
​
## Getting Started
​
Initial work on PAN-OS integration with ELK
Change IP from Logstash and Kibana to point toward Elasticsearch IP.
​
---
1. *logstash/config/logstash.yml*
```
xpack.monitoring.elasticsearch.hosts: [ "http://192.168.45.101:9200" ]
```

2. *kibana/config/kibana.yml*
```
elasticsearch.hosts: [ "http://192.168.45.101:9200" ]
```

3. *pipeline/PAN-OS9.conf*
```
output {hosts => ["192.168.45.101:9200"]}
```

### Prerequisites
​
## To Do
​
**Next steps**
- [x] Ingestion
- [x] Global Protect
- [ ] Threat logs
- [ ] Traffic logs
- [ ] System logs - parse per event ID (global protect and others)
​

**Optional**
- [ ] monitor global protect user delta between connection and disconnection
- [ ] automate provisionning to have less manual config
- [ ] beats ?

## References

[Elastic Search] (https://www.elastic.co/guide/en/kibana/current/saved-objects-api-import.html)
[Docker Compose] (docs.docker.com/compose/compose-file)

## Authors
* **Damien Raynal** - *main author*

### Contributors 

* **Victor Knell**

## License
​
This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/damray/panelk/blob/master/LICENSE.md) file for details