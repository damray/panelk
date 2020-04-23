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

### Installation

#### Ubuntu 18.04 LTS

Installation on Ubuntu LTS 18.04

```
sudo apt install docker docker-compose git -y
git clone https://github.com/damray/panelk
sudo systemctl start docker
sudo systemctl enable docker
cd panelk
```

Retrieve the output of the following command for your ip address:

```
ip addr
```

Launch docker-compose to download all images and scripts:

```
sudo docker-compose up
```

Elastic Search is now ready to be used.


#### Use as a syslog

On your Panorama or PAN-OS, create a new log forwarding profile to send all your logs to your newly created ELK stack.

To do so you can open a policy rule and go the the *Actions* tab en edit the *Log Settings*:

![Log Profile 1](https://github.com/damray/panelk/blob/master/images/log_profile-1.png)

Add a new *Profile*:

![Log Profile 2](https://github.com/damray/panelk/blob/master/images/log_profile-2.png)

Click on *Add* to add a new *Profile match*:

![Log Profile 3](https://github.com/damray/panelk/blob/master/images/log_profile-3.png)

Give a name, select a log type, here *traffic*, and add a syslog server:

![Log Profile 4](https://github.com/damray/panelk/blob/master/images/log_profile-4.png)

Add a new *Syslog Profile* by clicking on the + in the *Syslog* frame:

![Log Profile 5](https://github.com/damray/panelk/blob/master/images/log_profile-5.png)

Add your elk server using the information gathered previously, and change the *Tranport* and *Port* to **UDP or TCP 5514**:

![Log Profile 6](https://github.com/damray/panelk/blob/master/images/log_profile-6.png)

Add the remaining categories, *auth*, *data*, *threat*, *tunnel*, *url* and *wildfire* and click *OK*.
You should end up with the *Log Forwarding Profile* as below:

![Log Profile 7](https://github.com/damray/panelk/blob/master/images/log_profile-7.png)

Do the same for Device > Log Settings to send the System, Configuration, User-ID, HIP Match, GlobalProtect and IP-Tag

![Log Profile 8](https://github.com/damray/panelk/blob/master/images/log_profile-8.png)

Give a name to the *Log Settings* for each category, and add the *Syslog* server:

![Log Profile 9](https://github.com/damray/panelk/blob/master/images/log_profile-9.png)

Commit your changes to send the logs to the PAN ELK server.


### Log on on Kibana

Launch a web browser and use the ip address of your ubuntu server:
```
http://YOURIPADDRESS:5601
```

## To Do
​
**Next steps**
- [x] Global Protect for 9.1
- [ ] Global Protect for 9.0 and below


## References

[Elastic Search](https://www.elastic.co/guide/en/kibana/current/saved-objects-api-import.html)
[Docker Compose](docs.docker.com/compose/compose-file)

## Authors
* **Damien Raynal** - *main author*

### Contributors 

* **Jean-Baptiste Guglielmine**
	* *lead bruiteur*
	* *master debugger*  "alors là c'est pas bon" - "c'est moi ou il y a deux espaces ?"
	* *lead tips*

* **Victor Knell** - *lead README.md developer*

* **Fabien Desbrueres** - *lead geolocalisation*

## License
​This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/damray/panelk/blob/master/LICENSE.md) file for details

## DRAFT CHAPTER

## How to clean everything and delete all dockger image on your host
if you need to change mapping, you have to create a new index to use your new mapping in ES or because it's docker and if you dont mind to lose all your log you can reset all docker volume and image :

From the directory panelk
```
docker-compose down --volumes
docker rmi -f $(docker image ls -aq)
```

## Waiting for ES and Kibana to be "healthy"
In the Docker compose the panelk is configured to wait for the ElasticSearch and Kibana container to startup and be ready to accept requests before continuing :

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

There is a last container with the service name setup_panelk who execute a script.

The script check if ELK is alive and push several configuration :
- [x] object with index pattern
- [x] dashboard
- [x] elastic mapping template Threat and Traffic
- [ ] elastic mapping template URL and GP
- [x] elastic index creation
- [x] Kibana dashboard
​
