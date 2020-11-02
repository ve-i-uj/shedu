ARG FROM_IMAGE_NAME
FROM ${FROM_IMAGE_NAME}
LABEL maintainer="Aleksei Burov <burov_alexey@mail.ru>"

ARG ASSETS_PATH="assets"
ARG SCRIPTS_DIR="scripts"

COPY ${ASSETS_PATH} /opt/assets
COPY ${SCRIPTS_DIR}/docker-entrypoint.sh /opt/assets/docker-entrypoint.sh
COPY ${SCRIPTS_DIR}/tail_logs.sh /opt/assets/tail_logs.sh
COPY ${SCRIPTS_DIR}/wait-for-it.sh /opt/assets/wait-for-it.sh

RUN chmod +x /opt/assets/wait-for-it.sh

WORKDIR /opt/assets/

ENTRYPOINT bash docker-entrypoint.sh

