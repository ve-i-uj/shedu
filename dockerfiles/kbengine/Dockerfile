FROM centos:centos7 AS kbe-build-prerequisites
LABEL maintainer="Aleksei Burov <burov_alexey@mail.ru>"

yum groupinstall 'Development Tools' -y \
    && yum install mariadb-devel -y


FROM 
# TODO: нужно убрать tools и возможно bin
COPY kbengine/kbe /opt/kbe
# COPY kbengine/kbe/res /opt/app-root/res
# COPY kbengine/kbe/bin /opt/app-root/bin

