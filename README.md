HAProxy Load Balancer
===

[![Build Status](https://jenkins.ozgo.info/jenkins/buildStatus/icon?job=ghp-million12-docker-haproxy)](https://jenkins.ozgo.info/jenkins/job/ghp-million12-docker-haproxy/) 
[![GitHub Open Issues](https://img.shields.io/github/issues/million12/docker-haproxy.svg)](https://github.com/million12/docker-haproxy/issues)   
[![Stars](https://img.shields.io/github/stars/million12/docker-haproxy.svg?style=social&label=Stars)](https://github.com/million12/docker-haproxy/stargazers)
[![Fork](https://img.shields.io/github/forks/million12/docker-haproxy.svg?style=social&label=Fork)](https://github.com/million12/docker-haproxy/network/members)  
[![Release](https://img.shields.io/github/release/million12/docker-haproxy.svg)](http://microbadger.com/images/million12/haproxy.svg)

[![Docker build](https://dockeri.co/image/million12/haproxy)](https://hub.docker.com/r/million12/haproxy/)

Felling like supporting me in my projects use donate button. Thank You!  
[![PayPal](https://img.shields.io/badge/donate-PayPal-blue.svg)](https://www.paypal.me/POzgo)

HAProxy docker container [million12/haproxy](https://registry.hub.docker.com/u/million12/haproxy/) with ALPN and HTTP/2 support.

### Tags

Please specify tag when deploying for specific version.
Example:

`million12/haproxy:latest`  
`million12/haproxy:2.1.2`

### Features

* **Support for HTTP/2** with ALPN
* CentOS 7 based
* Ability to **provide any arguments to haproxy** process
  Any extra parameters provided to `docker run` will be passed directly to `haproxy` command.
  For example, if you run `docker run [run options] million12/haproxy -n 1000` you pass `-n 1000` to haproxy daemon.
* Pretty **lightweight**, only ~100M (with OpenSSL and HAProxy compiled from source).
* **Default [haproxy.cfg](container-files/etc/haproxy/haproxy.cfg) provided** for demonstration purposes. You can easily mount your own or point to different location using `HAPROXY_CONFIG` env.
* **Auto restart when config changes**
  This container comes with inotify to monitor changes in HAProxy config and **reload** HAProxy daemon. The reload is done in a way that no connection is lost.

### ENV variables

|Variable|Default Settings|Notes|
|:--|:--|:--|
|`HAPROXY_CONFIG`|`/etc/haproxy/haproxy.cfg`|If you mount your config to different location, simply edit it.|
|`HAPROXY_PORTS`|`80,443`|Comma separated ports|
|`HAPROXY_ADDITIONAL_CONFIG`|Empty|List of file that inotify should monitor for changes divided by space. Example below. Space separated|
|`HAPROXY_PRE_RESTART_CMD`|Empty|Command to execute before restarting haproxy|
|`HAPROXY_POST_RESTART_CMD`|Empty|Command to execute after successfully restarting haproxy|

## Usage

### Basic

```bash
docker run -ti \
  -p 80:80 \
  -p 443:443 \
  million12/haproxy
```

### Mount custom config , override some options

```bash
docker run -d \
  -p 80:80 \
  -v /my-haproxy.cfg:/etc/haproxy/haproxy.cfg \
  million12/haproxy \
  -n 10000
```

Note: in this case config is mounted to its default location, so you don't need to modify
`HAPROXY_CONFIG` variable.

### Monitor additional config files

```bash
docker run -d \
  -p 80:80 \
  -e HAPROXY_ADDITIONAL_CONFIG='/etc/haproxy/custom1 /etc/haproxy/custom2' \
  million12/haproxy
```

### Check version and build options

`docker run -ti million12/haproxy -vv`

### Stats

The default URL for stats is `http://CONTAINER_IP/admin?stats` with username:password ser to `admin:admin`.

---

## Authors

Author: Marcin ryzy Ryzycki (<marcin@m12.io>)  
Author: Przemyslaw Ozgo (<linux@ozgo.info>)
