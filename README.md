![Logo](https://user-images.githubusercontent.com/6612371/212449601-6d62e862-5dbc-4d79-9a61-47230f0b61bf.jpg)

Shedu is the project for easy deploy of a KBEngine cluster in Docker on Linux.

## Overview

The project builds, packages and starts [KBEngine](https://github.com/kbengine/kbengine "An open source MMOG server engine") and kbe environment in the docker containers.

The main goal of the project is to simplify kbengine deploy. You don't need to know how to build a C++ project or what library you need to install for. Moreover all kbe infrastructure (database, smtp server etc) can be built and started just in one command too. You can choose a kbe commit for your kbe build and easy link your "assets" to the chosen kbe version. Change variables in "configs/example.env" and save the file like a new one with your configuration.

You can run a KBEngine cluster for both KBEngine version 1.x or 2.x. (any commit).

The project also deployed tools for convenient collection and viewing of logs based on the ELK stack (Elasticsearch + Logstash + Kibana).

The project can be used for convenient local development, quick MVP creation, and quick testing of game development business ideas.

Tested on Ubuntu 20.04, CentOS 7, Ubuntu 22.04

![Docker environment](https://github.com/ve-i-uj/shedu/assets/6612371/e052407e-85b9-484e-9c8f-4801832ad9f5 "KBE docker environment")

## Table of contents

[Glossary](#glossary)

[Deploy](#deploy)

[Configuration file](#config)

[KBEngine logging (Elasticsearch + Logstash + Kibana)](#elk)

[Cocos2D build example](#cocos2d)

[Build activity](#build)

[Assets normalization](https://github.com/ve-i-uj/enki#normalize_entitiesxml)

[The script "modify_kbe_config"](https://github.com/ve-i-uj/enki#modify_kbe_config)

<a name="glossary"><h2>Glossary</h2></a>

* Host - the server with installed Docker and Docker Compose
* Shedu - this project. A utility that deploys a KBEngine cluster in the docker environment and gives API to manage the cluster

* [KBEngine](https://github.com/kbengine/kbengine) - server game engine in C++
* Assets - server game logic on Python + user server settings ([see the official KBEngine demo assets](https://github.com/kbengine/kbengine_demos_assets))
* Game - KBEngine + Assets

* Engine image - a docker image containing only built KBEngine
* Game image - a docker image containing built KBEngine + Assets

* KBEngine Component - A system process with a given responsibility in a gaming business process
    * Machine / Supervisor - stores information about running components (their id, address, etc.)
    * Logger - collects and writes log files of components
    * Interfaces - to access third party billing, third party accounts and third party databases
    * DBMgr - manages communication with the database. Creates and modifies the database schema according to the configuration files of the game (assets). Responsible for saving entities in the DB
    * BaseappMgr - manages load balancing for BaseApps. Responsible for fault tolerance of BaseApps
    * CellappMgr - keeps track of all CellApps and their loading, distributes the creation of game entities among CellApps
    * Cellapp - processing game logic related to space or location. Managing spatial data (position, direction of the entity), adding geometric maps (navmesh), setting spatial triggers. Creating and Destroying a Level
    * Baseapp - keeps a connection with the client after loginapp is authenticated. Proxy calls to Cellapp. Used for game logic of non-spatial objects (chats, managers, clans)
    * Loginapp - connection point for clients. Responsible for authentication of the game client. After successful authentication passes Basseapp address for subsequent connection
* KBEngine Environment - a set of services around game engine components: database, smtp server, web server (for Kosos2D, for example), etc.
* KBEngine Cluster - KBEngine Component + KBEngine Environment

* Client - plugin supporting network protocol KBEngine + game engine (Cocos2D, Unity, Godot, UE etc.)

<a name="deploy"><h2>Deploy</h2></a>

Download the project

```bash
git clone https://github.com/ve-i-uj/shedu
cd shedu
git submodule update --init --recursive
```

### Install Docker and Compose

This project uses Docker, so you need to install [Docker](https://docs.docker.com/desktop/install/linux-install/) and [Docker Compose V2](https://docs.docker.com/ compose /install/) if they are not installed. You can install them according to the official docker documentation, or [at your own risk] install them using the scripts that come with this project. If both Docker and Docker-compose are installed on the host, you can skip this step.

```bash
bash scripts/prepare/install_docker.sh
bash scripts/prepare/install_compose_v2.sh
```

The user will added to the "docker" group. It need to logout and to login again for changing is applyed.

### Install Dependencies

```bash
# This script will install make git python3
./configure
```

### The configuration file

The project reads the settings from the ".env" file located in the root directory. There are [examples](configs/example.env) of .env files in the "configs" directory. By default, without changing the settings, the game server will be launched with [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets). You can start the kbe server with your "assets" just point in the .env file the directory of your "assets". For more information see settings [described here](#configuration-file). Copy an example env file to the root directory and change it if you want set your custom settings.

```bash
cp configs/example.env .env
```

### Build KBEngine

There are several already built kbe images on [Docker Hub](https://hub.docker.com/repository/registry-1.docker.io/shedu/kbe-compiled/), so building a kbe might take just a few minutes (or a few seconds later if docker cache is used).

```bash
make build_kbe
```

Build the game

```bash
make build_game
```

Launch the game

```bash
make start_game
```

Delete game artifacts

```bash
make clean_game
```

View `logs` from the console (or view `logs` in [ELK web interface](#elk))

```bash
make logs_console
```

Other operations

```bash
make help
```

To switch games between each other, you only need to stop the instance of the running game. Then change the configuration ".env" file (or copy the already existed file), build the image (if not built) and run an instance of another game. If the image of another game exists, then all you need to do is stop the services, change the config for the new game, and start its services. There is no need to delete images of the old game. By keeping the docker images of the previous version of the game, you can switch and run different game instances very quickly (less than a minute).

Currently, only one game and ELK instance can be running at the same time on the same host. This is due to a port conflict. Theoretically, if you change the ports in the docker-compos.yml file, you can run several games at the same time, but this functionality has not yet been tested.

<a name="config"><h2>Configuration file</h2></a>

The configuration file should be placed in the project root and has the name ".env". There are some examples in the [configs](configs) directory.

```bash
cp configs/kbe-v2.5.12-demo.env .env
```

Set the path to Assets in the KBE_ASSETS_PATH variable in the config (the ".env" file). The path to Assets must be an absolute path pointing to your "assets" folder on your host. This "assets" folder will be copied into the game image. If KBE_ASSETS_PATH value is "demo", the latest version of [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets) will be downloaded and will be used (these Assets are suitable for Kbengine client demos). For demo purpose you need just copy an example config file like in the above command.

![Settings](https://github.com/ve-i-uj/shedu/assets/6612371/5372b7e8-e136-4e9b-b678-cb2e30718518)

#### Database build settings

* MYSQL_ROOT_PASSWORD - database root password
* MYSQL_DATABASE - database name
* MYSQL_USER - database user
* MYSQL_PASSWORD - database password

#### KBE build settings

* KBE_GIT_COMMIT - # KBEngine will be compiled from the source code based on a git commit. The latest commit of the kbe repository will be use if the value of the variable is unset. Example: 7d379b9f
* KBE_USER_TAG - Tag the compiled kbengine image with this tag. For example: v2.5.12

#### Game assets settings

* KBE_ASSETS_PATH - Absolute path to the "assets" directory. If set to "demo", the kbe demo "assets" will be used (https://github.com/kbengine/kbengine_demos_assets.git)
* KBE_ASSETS_SHA - You can set the "assests" git sha if the "assets" is a git project. Example: 81f7249b
* KBE_ASSETS_VERSION - The version of the "assets". This variable labels the finaly game image, it cannot be empty. Set any non-empty string if your project has no version.
* KBE_KBENGINE_XML_ARGS - With this field, you can change the values of the fields in kbengine.xml in the final image of the game. Example: (example: KBE_KBENGINE_XML_ARGS=root.dbmgr.account_system.account_registration.loginAutoCreate=true;root.whatever=123)
* KBE_PUBLIC_HOST - The external address of the server where the cluster packaged in Docker will be deployed. For home development, when both client and server are on the same computer, you can use the default gateway address.

#### Global Settings

* GAME_NAME - For each instance of the game there is a separate kbe environment. The name of the game is a unique identifier for the kbe environments. It cannot be empty.

#### Develop Settings

* GAME_IDLE_START - If this variable has any value, cluster containers are started without processes of kbe components. It needs to the VSCode debugger will launch the kbe component in the container later and attach to the kbe component's process. The health check of components will be disabled if this variable are set.
* DEBUG_SUPERVISOR - The Supervisor container is started under debugging via debugpy. After starting, you can connect to it with the VSCode debugger on port 18198. To activate the variable, you need to set any value.
* ENKI_PATH - The path to the Enki library. If the variable is empty, the version from the git submodule will be used. The variable can be used while developing something in Enki and testing the functionality.

<a name="elk"><h2>KBEngine logging (Elasticsearch + Logstash + Kibana)</h2></a>

The Shedu project demonstrates the use of the ELK stack ([Elastic + Logstash + Kibana](https://www.elastic.co/what-is/)) to easily view KBEngine logs. You can conveniently save game server logs in Elasticsearch and conveniently view them through Kibana or Dejavu (frontends for Elasticsearch) .

ELK services are docker images. The state is stored in a named volume created for each game. Services are launched using docker-compose and at the start the containers are associated with the desired volume.  The ELK version is v8.5.3.

Before starting, you need to build the service images if they are not already built and then start the services.

```bash
make build_elk
make start_elk
```

The ELK will take some time to start, so after the start, you need to wait a few minutes for the ELK to be available. Open web interfaces to view logs:

```bash
# The "logs_kibana" rule exports some user settings to the Kibana view before opening the web page
make logs_kibana
make logs_dejavu
```

![ELK](https://github.com/ve-i-uj/shedu/assets/6612371/0d28badf-f64f-47a4-a392-a1b8ca1332b8)

<details>

<summary>Dejavu page</summary>

![Dejavu](https://github.com/ve-i-uj/shedu/assets/6612371/b0d39d2f-bb8e-4a9f-add5-46b8de9c4a5a)

</details>
<br/>

For documentation on using [Kibana](https://www.elastic.co/kibana/) or [Dejavu](https://github.com/appbaseio/dejavu) see official sites.

The life cycles of game services and ELK services are independent. ELK will work without a running game; similarly with the game: the game works without ELK.

## Logging in KBEngine (brief overview)

At the engine level, the log4cxx library (log4j for C++) is used for logging. The default configuration files for log4j are located in the directory [kbe/res/server/log4cxx_properties_defaults](https://github.com/kbengine/kbengine/tree/master/kbe/res/server/log4cxx_properties_defaults). This directory contains a separate file for each component. The logging settings can be reloaded by defining custom log4j settings in the `res/server/log4cxx_properties` folder.

By default, logs are written to the `assets/logs` directory. If all KBEngine server components are located on the same host, all logs will be in this folder. By default, each component sends all logs to the Logger component (using the KBEngine message protocol). Then Logger writes the received logs to the `assets/logs` folder. The file name for log records has the following pattern: `logger_<compnent_name>`. Some of the critical logs (errors and warnings) are written by the components to the `assets/logs` folder under their own name (for example, "machine.log").

## General principle of operation of KBEngine + ELK for collecting logs

Operating procedure:

* KBEngine default settings remain unchanged (logs are still written to the `logs` directory)
* The `logs` folder of the container is mounted in a separate volume created for the logs
* This volume is mounted to the container with Logstash
* Logstash collects all new records from the `logs` folder, normalizes them and sends them to Elasticsearch
* Elasticsearch stores documents in its own volume (the ES volume and the log volume are different volumes)
* To view the logs stored in Elasticsearch, you can use the web interfaces of Kibana or Dejavu services locally running in Docker

Logstash configuration settings are located in the `shedu/data/logstash` folder. To customize the logging fields, you can modify the [grok](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html) pattern ["LOG_MESSAGE"](data/logstash/kbe_patterns). It is convenient to combine customization of this pattern with game scripts logging using the python language ([logging module](https://docs.python.org/3/library/logging.html)). An example of setting up logging of game scripts using Python can be found [here](https://github.com/ve-i-uj/anu/blob/develop/scripts/server_common/sclog.py).

Stopping ELK services

```bash
make stop_elk
```

Cleaning up ELK services

```bash
make clean_elk
```

<a name="build"><h2>Build activity</h2></a>

![Build kbe](https://user-images.githubusercontent.com/6612371/212449373-9935364b-7144-4880-9144-e2b19a6fbb22.jpg)
![Build Assets](https://user-images.githubusercontent.com/6612371/212449374-f39cc7ad-2b50-4f22-804d-929be1c680c7.jpg)

<a name="cocos2d"><h2>Cocos2D example</h2></a>

Below is an example of building a server cluster and running [the demo client on Cocos2D](https://github.com/kbengine/kbengine_cocos2d_js_demo).

To run the example, we need KBEngine version v1.3.5 (commit 26e95776) and assets version v1.3.5 (commit eb034a2e). All you need to deploy a cluster of this version using the Shedu is to specify these commits in the configuration file.

<details>

<summary>This is what the config file will look like</summary>

    MYSQL_ROOT_PASSWORD=pwd123456
    MYSQL_DATABASE=kbe
    MYSQL_USER=kbe
    MYSQL_PASSWORD=pwd123456

    KBE_GIT_COMMIT=26e95776
    KBE_USER_TAG=v1.3.5

    KBE_ASSETS_PATH=demo
    KBE_ASSETS_SHA=eb034a2e
    KBE_ASSETS_VERSION=v1.3.5

    GAME_NAME=cocos-demo
    GAME_IDLE_START=

    KBE_PUBLIC_HOST=0.0.0.0

</details>
<br/>

The directory [configs](configs) already have a ready-made config for a client on Cocos2D. Just copy it and then build and run the cluster. If a cluster for another game is running, you must first stop it and only then copy the config.

Attention! If the client and the KBEngine cluster are running on different computers, the KBE_PUBLIC_HOST variable must be set to the address of the computer running KBEngine, otherwise the client will not be able to connect to the server. The address must be set before building the KBEngine cluster.

```bash
cp configs/kbe-v1.3.5-cocos-js-v1.3.13-demo-v1.3.5.env .env
make build_game
make start_game
```

And that's it, the server is running. Server logs can be viewed like this

```bash
make logs_console
```

Next, run the game client on Cocos2D. To run the client, you need a web server. To make the demonstration easier I have added a Dockerfile for Cocos2D client build. There are also several rules in Makefile for build, start, stop and cleanup the client.

<details>

<summary>Dockerfile.cocos-demo</summary>

```dockerfile
    FROM nginx:1.23.3 as demo_client
    LABEL maintainer="Aleksei Burov <burov_alexey@mail.ru>"

    WORKDIR /opt
    RUN apt-get update && apt-get install git -y
    RUN git clone https://github.com/kbengine/kbengine_cocos2d_js_demo.git \
        && cd /opt/kbengine_cocos2d_js_demo \
        && git submodule update --init --remote

    # Replace with host address where Loginapp KBEngine is located
    ARG KBE_PUBLIC_HOST=0.0.0.0
    WORKDIR /opt/kbengine_cocos2d_js_demo
    RUN sed -i -- "s/args.ip = \"127.0.0.1\";/args.ip = \"$KBE_PUBLIC_HOST\";/g" cocos2d-js-client/main.js

    FROM nginx:1.23.3
    COPY --from=demo_client /opt/kbengine_cocos2d_js_demo/cocos2d-js-client /usr/share/nginx/html
```

</details>
<br/>

To build the client, an Nginx image is taken, a demo client is cloned into it, and the address of the KBEngine server is specified in the client code.

```bash
make cocos_build
make cocos_start
```

![Cocos2D](https://github.com/ve-i-uj/shedu/assets/6612371/b983bab8-db57-4617-beaf-cd57a600ab62)
