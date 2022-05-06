FROM rockylinux:latest

ENV   HAPROXY_MJR_VERSION=2.4 \
  HAPROXY_VERSION=2.4.16 \
  HAPROXY_CONFIG='/etc/haproxy/haproxy.cfg' \
  HAPROXY_ADDITIONAL_CONFIG='' \
  HAPROXY_PRE_RESTART_CMD='' \
  HAPROXY_POST_RESTART_CMD='' \
  OPENSSL_VERSION=3.0.2

RUN \
  yum install -y epel-release && \
  yum update -y && \
  `# Install build tools. Note: perl needed to compile openssl...` \
  yum install -y \
    inotify-tools \
    wget \
    tar \
    gzip \
    make \
    gcc \
    perl \
    pcre-devel \
    zlib-devel \
    iptables \
    socat \
    nc \
    telnet \
    mtr && \
  `# Install newest openssl...` \
  wget -O /tmp/openssl.tgz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
  tar -zxf /tmp/openssl.tgz -C /tmp && \
  cd /tmp/openssl-* && \
  ./config \
    --openssldir=/etc/pki/tls \
    no-shared zlib-dynamic && \
  make -j$(getconf _NPROCESSORS_ONLN) V= && make install_sw && \
  cd && rm -rf /tmp/openssl* && \
  wget -O /tmp/haproxy.tgz http://www.haproxy.org/download/${HAPROXY_MJR_VERSION}/src/haproxy-${HAPROXY_VERSION}.tar.gz && \
  tar -zxvf /tmp/haproxy.tgz -C /tmp && \
  cd /tmp/haproxy-* && \
  make \
  -j$(getconf _NPROCESSORS_ONLN) V= \
  TARGET=linux-glibc \
  USE_LINUX_TPROXY=1 \
  USE_ZLIB=1 \
  USE_REGPARM=1 \
  USE_PCRE=1 \
  USE_PCRE_JIT=1 \
  USE_OPENSSL=1 \
  ADDLIB=-ldl \
  ADDLIB=-lpthread && make install && \
  rm -rf /tmp/haproxy* && \
  mkdir -p /var/lib/haproxy && \
  groupadd haproxy && adduser haproxy -g haproxy && chown -R haproxy:haproxy /var/lib/haproxy && \
  openssl genrsa -out /etc/pki/tls/dummy.key 2048 && \
  openssl req -new -key /etc/pki/tls/dummy.key -out /etc/pki/tls/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=haproxy" && \
  openssl x509 -req -days 3650 -in /etc/pki/tls/dummy.csr -signkey /etc/pki/tls/dummy.key -out /etc/pki/tls/dummy.crt && \
  cat /etc/pki/tls/dummy.crt /etc/pki/tls/dummy.key > /etc/pki/tls/dummy.pem && \
  yum remove -y make gcc pcre-devel && \
  yum clean all && rm -rf /var/cache/yum

COPY container-files /

ENTRYPOINT ["/bootstrap.sh"]
