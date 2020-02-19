FROM alpine:3.11.3
ARG VERSION=1.12.0

# Forked from https://github.com/edoburu/docker-pgbouncer/blob/master/Dockerfile
RUN \
  # Download
  apk --update --no-cache add \
    autoconf \
    autoconf-doc \
    automake \
    c-ares \
    c-ares-dev \
    curl \
    gcc \
    libc-dev \
    libevent \
    libevent-dev \
    libtool \
    make \
    libressl-dev \
    pkgconf \
    postgresql-client

WORKDIR /tmp
RUN curl -o  pgbouncer-$VERSION.tar.gz -L https://pgbouncer.github.io/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz

RUN mkdir /tmp/pgbouncer && \
        tar -zxvf pgbouncer-$VERSION.tar.gz -C /tmp/pgbouncer --strip-components 1

WORKDIR /tmp/pgbouncer

RUN ./configure --prefix=/usr && \
        make

RUN cp pgbouncer /usr/bin && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  # entrypoint installs the configuation, allow to write as postgres user
  cp etc/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini.example && \
  cp etc/userlist.txt /etc/pgbouncer/userlist.txt.example

RUN adduser -S postgres
RUN chown -R postgres /var/run/pgbouncer /etc/pgbouncer
  # Cleanup
RUN cd /tmp && \
  rm -rf /tmp/pgbouncer*
ADD entrypoint.sh /entrypoint.sh

EXPOSE 6432
RUN ["chmod", "+x", "/entrypoint.sh"]
USER postgres
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]