FROM centos:centos7
MAINTAINER Marcin Ryzycki marcin@m12.io, Przemyslaw Ozgo linux@ozgo.info

ENV HAPROXY_VERSION=1.5.14

RUN \
  yum install -y epel-release && \
  yum install -y inotify-tools wget tar gzip make gcc pcre-devel openssl-devel && \
  wget -O /tmp/haproxy.tgz http://www.haproxy.org/download/1.5/src/haproxy-${HAPROXY_VERSION}.tar.gz && \
  mkdir -p /usr/local/haproxy && \
  tar -zxvf /tmp/haproxy.tgz -C /usr/local/haproxy/ --strip-components 1 && \
  rm -f /tmp/haproxy.tgz && \
  cd /usr/local/haproxy && \
  make \
  USE_LINUX_TPROXY=1 USE_ZLIB=1 \
  USE_REGPARM=1 \
  USE_OPENSSL=1 \
  USE_PCRE=1 \
  TARGET=linux2628 \
  CFLAGS="-O2 -g -fno-strict-aliasing -DTCP_USER_TIMEOUT=18" && \
  make install && \
  yum remove -y make gcc pcre-devel openssl-devel && \
  yum clean all && \
  rm -rf /usr/local/haproxy && \
  mkdir -p /var/lib/haproxy && \
  groupadd haproxy && adduser haproxy -g haproxy && chown -R haproxy:haproxy /var/lib/haproxy

COPY container-files /

ENV HAPROXY_CONFIG /etc/haproxy/haproxy.cfg

EXPOSE 80 443

ENTRYPOINT ["/bootstrap.sh"]
