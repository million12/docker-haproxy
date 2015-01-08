FROM centos:centos7
MAINTAINER Marcin Ryzycki marcin@m12.io, Przemyslaw Ozgo linux@ozgo.info

RUN \
    yum install -y epel-release && \
    yum install -y haproxy inotify-tools && \
    yum clean all

COPY container-files /

ENV HAPROXY_CONFIG /etc/haproxy/haproxy.cfg

EXPOSE 80 443

ENTRYPOINT ["/bootstrap.sh"]
