FROM centos:centos7
MAINTAINER Marcin Ryzycki marcin@m12.io

RUN yum install -y haproxy && yum clean all
ADD haproxy/ /etc/haproxy/

EXPOSE 80 443

ENTRYPOINT ["/usr/sbin/haproxy"]
CMD ["-vv"]
