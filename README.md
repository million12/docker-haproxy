# HAProxy Load Balancer 
[![Circle CI](https://circleci.com/gh/million12/docker-haproxy/tree/master.svg?style=svg)](https://circleci.com/gh/million12/docker-haproxy/tree/master)

This is a [million12/haproxy](https://registry.hub.docker.com/u/million12/haproxy/) docker container with HAProxy load balancer. This work is very similar to official [dockerfile/haproxy](https://registry.hub.docker.com/u/dockerfile/haproxy/), but it's based on CentOS-7 and, more importantly, offers ability to provide any arguments to haproxy process. It's also pretty lightweight, only ~236M (vs. ~420M Ubuntu-based dockerfile/haproxy).

This container is built with `ENTRYPOINT` set to `haproxy`, so when you run it, it behaves as you'd run haproxy binary. Therefore **you can pass any extra options, which will be passed directly to haproxy**.

The default [haproxy.cfg](haproxy/haproxy.cfg) is provided just for demonstration purposes, so of course you will want to override it. 

## INotify
This image comes with inotifywatch for monitoring changes to `haproxy.cfg` at `/etc/haproxy/` and **reloading** not restarting HAProxy whn configuration file has been changed. Thanks to this lost packets should be done to minimum. 
 

## Usage

### Basic

`docker run -ti -p 80:80 -p 443:443 million12/centos-haproxy -f /etc/haproxy/haproxy.cfg`

### Mount custom config, override some options

`docker run -d -p=80:80 -p=443:443 -v=/data/haproxy/haproxy.cfg:/etc/haproxy/haproxy.cfg million12/haproxy -f /etc/haproxy/haproxy.cfg -n 10000`

### Check version and build options

`docker run -ti million12/haproxy`

### Stats /uri
Access web uri is set to `/admin?stats` and default user and password ser to `admin:admin`.
Go to [http://127.0.0.1/admin?stats](http://127.0.0.1/admin?stats) to access stats

## Authors

Author: Marcin ryzy Ryzycki (<marcin@m12.io>)  
Author: Przemyslaw Ozgo (<linux@ozgo.info>)  

---

**Sponsored by** [Typostrap.io - the new prototyping tool](http://typostrap.io/) for building highly-interactive prototypes of your website or web app. Built on top of TYPO3 Neos CMS and Zurb Foundation framework.
