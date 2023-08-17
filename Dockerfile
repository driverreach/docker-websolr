
FROM    openjdk:8-jre

RUN apt-get update && \
  apt-get -y install lsof procps wget gpg && \
  rm -rf /var/lib/apt/lists/*

ENV SOLR_PORT=8981 \
    SOLR_USER="solr" \
    SOLR_GROUP="solr" \
    SOLR_VERSION="4.10.2" \
    SOLR_URL="${SOLR_DOWNLOAD_SERVER:-https://archive.apache.org/dist/lucene/solr}/4.10.2/solr-4.10.2.tgz" \
    SOLR_SHA256="101bc6b02ac637ac09959140a341e6b02d8409f3f84c37b36c7628c6f8739c1f" \
    PATH="/opt/solr/bin:/opt/docker-solr/scripts:$PATH"

RUN groupadd -r $SOLR_GROUP && \
  useradd -r -g $SOLR_GROUP $SOLR_USER

RUN mkdir -p /opt/solr && \
  echo "downloading $SOLR_URL" && \
  wget -nv $SOLR_URL -O /opt/solr.tgz && \
  echo "downloading $SOLR_URL.asc" && \
  wget -nv $SOLR_URL.asc -O /opt/solr.tgz.asc && \
  echo "$SOLR_SHA256 */opt/solr.tgz" | sha256sum -c - && \
  (>&2 ls -l /opt/solr.tgz /opt/solr.tgz.asc) && \
  tar -C /opt/solr --extract --file /opt/solr.tgz --strip-components=1 && \
  rm /opt/solr.tgz* && \
  rm -Rf /opt/solr/docs/ && \
  mkdir -p /opt/solr/server/solr/lib /opt/solr/server/solr/mycores /opt/solr/server/logs /docker-entrypoint-initdb.d /opt/docker-solr && \
  sed -i -e 's/"\$(whoami)" == "root"/$(id -u) == 0/' /opt/solr/bin/solr && \
  sed -i -e 's/lsof -PniTCP:/lsof -t -PniTCP:/' /opt/solr/bin/solr && \
  sed -i -e '/-Dsolr.clustering.enabled=true/ a SOLR_OPTS="$SOLR_OPTS -Dsun.net.inetaddr.ttl=60 -Dsun.net.inetaddr.negative.ttl=60"' /opt/solr/bin/solr.in.sh && \
  chown -R $SOLR_USER:$SOLR_GROUP /opt/solr

COPY scripts /opt/docker-solr/scripts
RUN chown -R $SOLR_USER:$SOLR_GROUP /opt/docker-solr

COPY custom/solr /home/solr
RUN chown -R $SOLR_USER:$SOLR_GROUP /home/solr

EXPOSE 8981
WORKDIR /opt/solr
USER $SOLR_USER

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground"]
