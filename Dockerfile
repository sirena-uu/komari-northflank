FROM ghcr.io/komari-monitor/komari:latest

RUN apk add --no-cache git bash tar gzip dcron tzdata

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /backup.sh
RUN chmod +x /entrypoint.sh /backup.sh

ENTRYPOINT ["/entrypoint.sh"]
