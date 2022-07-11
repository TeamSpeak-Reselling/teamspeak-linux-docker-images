FROM alpine:3.10

RUN apk add --no-cache ca-certificates libstdc++ su-exec libpq curl
RUN set -eux; \
    addgroup -g 9987 ts3server; \
    adduser -u 9987 -Hh /var/ts3server -G ts3server -s /sbin/nologin -D ts3server; \
    install -d -o ts3server -g ts3server -m 775 /var/ts3server /var/run/ts3server /opt/ts3server

ENV PATH "${PATH}:/opt/ts3server"

ARG VERSION="3.13.7"

ARG TEAMSPEAK_URL="https://files.teamspeak-services.com/releases/server/${VERSION}/teamspeak3-server_linux_alpine-${VERSION}.tar.bz2"

RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps tar; \
    wget "${TEAMSPEAK_URL}" -O server.tar.bz2; \
    mkdir -p /opt/ts3server; \
    tar -xf server.tar.bz2 --strip-components=1 -C /opt/ts3server; \
    rm server.tar.bz2; \
    apk del .fetch-deps; \
    mv /opt/ts3server/*.so /opt/ts3server/redist/* /usr/local/lib; \
    ldconfig /usr/local/lib

VOLUME /var/ts3server/
WORKDIR /var/ts3server/

COPY entrypoint.sh /opt/ts3server
COPY defaults.sql /opt/ts3server/sql

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "ts3server" ]
