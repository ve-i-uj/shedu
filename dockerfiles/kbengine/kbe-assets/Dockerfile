ARG FROM_IMAGE_NAME
FROM ${FROM_IMAGE_NAME}
LABEL maintainer="Aleksei Burov <burov_alexey@mail.ru>"

# TODO: configure source of assets
COPY assets /opt/assets
COPY scripts/docker-entrypoint.sh /opt/assets/docker-entrypoint.sh
COPY scripts/tail_logs.sh /opt/assets/tail_logs.sh
COPY scripts/wait-for-it.sh /opt/assets/wait-for-it.sh
RUN chmod +x /opt/assets/wait-for-it.sh

WORKDIR /opt/assets/

ENTRYPOINT bash docker-entrypoint.sh

