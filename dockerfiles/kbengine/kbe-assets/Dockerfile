ARG FROM_IMAGE_NAME
FROM ${FROM_IMAGE_NAME}
LABEL maintainer="Aleksei Burov <burov_alexey@mail.ru>"

ARG ASSETS_PATH="assets"
ARG SCRIPTS_DIR="scripts"

RUN yum install python3 -y
# For debug
RUN yum install net-tools -y

COPY ${ASSETS_PATH} /opt/assets
COPY ${SCRIPTS_DIR}/* /opt/assets/

# Update kbengine.xml file
ARG HOST_ADDR
RUN HOST_ADDR=${HOST_ADDR} python3 /opt/assets/modify_kbe_config.py

RUN chmod +x /opt/assets/wait-for-it.sh

WORKDIR /opt/assets/

ENTRYPOINT bash docker-entrypoint.sh

