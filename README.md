# PAN-OS Elk integration

Initial work on PAN-OS integration with ELK

## Getting Started

### Prerequisites

#### System

**Minimum**
- CPU: 2 cores
- RAM: 4GB

**Recommanded**
- CPU: 4 cores
- RAM: 8GB

#### Software

- linux based os (tested on Ubuntu 18.04 LTS)
- docker
- docker compose

### Changes

Change IP from Logstash and Kibana to point toward Elasticsearch IP

---
1. *kibana/config/kibana.yml*
```
elasticsearch.hosts: [ "http://192.168.45.101:9200" ]
```

2. *logstash/config/logstash.yml*
```
xpack.monitoring.elasticsearch.hosts: [ "http://192.168.45.101:9200" ]
```

3. *logstash/pipeline/PAN-OS9.conf*
```
output {hosts => ["192.168.45.101:9200"]}
```

4. *logstash/pipeline/logstash.conf*
```
output {hosts => ["192.168.45.101:9200"]}
```
---

To change the address using vi enter the following command:
```
:%s/192.168.45.101/YOURIP/g
```

### Ubuntu 18.04 LTS

Installation on Ubuntu LTS 18.04

```
git clone https://github.com/damray/panelk
sudo apt install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
cd panelk
# See **changes** first
sudo docker-compose up
```

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

[Elastic Search](https://www.elastic.co/guide/en/kibana/current/saved-objects-api-import.html)

[Docker Compose](docs.docker.com/compose/compose-file)

## Authors
* **Damien Raynal** - *main author*

### Contributors 

* **Jean-Baptiste Guglielmine**
	* *lead bruiteur*
	* *master debugger "alors là c'est pas bon"*
	* *lead tips*

* **Victor Knell** - *lead README.md developer*

## License
​This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/damray/panelk/blob/master/LICENSE.md) file for details

## DRAFT CHAPTER

## Waiting for ES and Kibana to be "healthy"
We can configure docker-compose to wait for the ElasticSearch and Kibana container to startup and be ready to accept requests before continuing :

The following healthcheck has been configured to periodically check if ES and Kibana are ready using the `curl` command. See the documentation for `ElasticSearch` command [here](https://www.postgresql.org/docs/9.4/static/app-pg-isready.html).
```yml
healthcheck:
  test: curl -s -f http://elastic:changeme@localhost:9200/_cat/health; if [[ $$? == 52 ]]; then echo 0; else echo 1; fi
    interval: 30s
    timeout: 10s
    retries: 5
```
If the check is successful the container will be marked as `healthy`. Until then it will remain in an `unhealthy` state.
For more details about the healthcheck parameters `interval`, `timeout` and `retries` see the documentation [here](https://docs.docker.com/engine/reference/builder/#healthcheck).

The container "curl" will configure ElasticSearch and Kibana when the 2 container healthcheck will bi `healthy`. The Curl Services depend on ES and Kibana and can be configured with the `depends_on` parameter as follows:
```yml
depends_on:
  kibana:
    condition: service_healthy
```
It's will be also possible to create a chain, ElasticSearch < Logstash < Kibana < Curl 