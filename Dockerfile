FROM debian:12

ENV   HAPROXY_MJR_VERSION=2.8 \
  HAPROXY_VERSION=2.8.1 \
  HAPROXY_CONFIG='/etc/haproxy/haproxy.cfg' \
  HAPROXY_ADDITIONAL_CONFIG='' \
  HAPROXY_PRE_RESTART_CMD='' \
  HAPROXY_POST_RESTART_CMD='' \
  OPENSSL_VERSION=3.1.1

RUN \
  apt update && \
  `# Install build tools. Note: perl needed to compile openssl...` \
  apt install -y \
    inotify-tools \
    wget \
    tar \
    gzip \
    make \
    gcc \
    perl \
    libpcre3-dev \
    zlib1g-dev \
    iptables \
    socat \
    netcat-traditional \
    telnet \
    mtr && \
  `# Install newest openssl...` \
  wget -O /tmp/openssl.tgz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
  tar -zxf /tmp/openssl.tgz -C /tmp && \
  cd /tmp/openssl-* && \
  ./config \
    --openssldir=/etc/ssl \
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
  adduser --no-create-home --disabled-password --gecos "" haproxy && adduser haproxy haproxy && chown -R haproxy:haproxy /var/lib/haproxy && \
  mkdir -p /etc/pki/tls && \
  openssl genrsa -out /etc/ssl/private/dummy.key 2048 && \
  openssl req -new -key /etc/ssl/private/dummy.key -out /etc/ssl/private/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=haproxy" && \
  openssl x509 -req -days 3650 -in /etc/ssl/private/dummy.csr -signkey /etc/ssl/private/dummy.key -out /etc/ssl/private/dummy.crt && \
  cat /etc/ssl/private/dummy.crt /etc/ssl/private/dummy.key > /etc/ssl/private/dummy.pem && \
  apt remove -y make gcc libpcre3-dev && \
  apt clean -y

COPY container-files /

ENTRYPOINT ["/bootstrap.sh"]
