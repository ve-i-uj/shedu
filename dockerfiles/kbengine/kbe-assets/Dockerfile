ARG FROM_IMAGE_NAME
FROM ${FROM_IMAGE_NAME}
LABEL maintainer="Aleksei Burov <burov_alexey@mail.ru>"

COPY kbengine_demos_assets /opt/assets

WORKDIR /opt/assets/

ENTRYPOINT bash ./start_server.sh

