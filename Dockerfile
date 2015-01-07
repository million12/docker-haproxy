FROM centos:centos7
MAINTAINER Marcin Ryzycki marcin@m12.io, Przemyslaw Ozgo linux@ozgo.info

COPY container-files /

RUN \
    yum install -y epel-release && \
    yum install -y haproxy inotify-tools && \
    yum clean all

EXPOSE 80 443

ENTRYPOINT ["/data/init/bootstrap.sh"]
CMD ["-vv"]
