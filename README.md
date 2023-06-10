![Logo](https://user-images.githubusercontent.com/6612371/212449601-6d62e862-5dbc-4d79-9a61-47230f0b61bf.jpg)

Shedu - Easy deploy of a KBEngine cluster

## Overview

The project builds, packages and starts [KBEngine](https://github.com/kbengine/kbengine "An open source MMOG server engine") and kbe environment in the docker containers.

The main goal of the project is to simplify kbengine deploy. It doesn't need to know how to build a C++ project or what library you need to install for. Moreover all kbe infrastructure (database, smtp server etc) can be built and started just in one command too. You can choose a kbe commit for your kbe build and easy link assets to the chosen kbe version. Change variables in "configs/example.env" and save the file like a new one with your configuration.

![Docker environment](https://user-images.githubusercontent.com/6612371/215063709-d279db1c-0efa-43f8-b204-58fa732d315f.jpg "KBE docker environment")

## Table of contents

[Glossary](#glossary)

[Deploy](#deploy)

[Configuration file](#config)

[KBEngine logging (Elasticsearch + Logstash + Kibana)](#elk)

[Assets normalization](#normalize_entitiesxml)

[Build activity](#build)

<a name="glossary"><h2>Glossary</h2></a>

* Host - the server with installed Docker and Docker Compose
* Shedu - this project. A utility that deploys a KBEngine cluster in the docker environment and interacts with this cluster

* KBEngine - server game engine in C++
* Assets - game logic on Python + user server settings
* Game - KBEngine + Assets

* Engine image - a docker image containing only built KBEngine
* Game image - a docker image containing KBEngine + Assets

<a name="deploy"><h2>Deploy</h2></a>

Download the project

```bash
git clone https://github.com/ve-i-uj/shedu
cd shedu
git submodule update --init --recursive
```

This project uses Docker. You need to install [Docker](https://docs.docker.com/desktop/install/linux-install/) and [Docker-compose](https://docs.docker.com/compose/install/) if they are not installed. You can install them according to their official documentation or [at your own risk] install them using the scripts that come with this project. If both Docker and Docker-compose exists on the host, you can skip this step.

```bash
bash scripts/prepare/install_docker.sh
bash scripts/prepare/install_compose_v2.sh
```

The user will added to the "docker" group. It need to logout and to login again for changing is applyed.

Install Dependencies

```bash
./configure
```

The project reads the settings from the ".env" file located in the root directory. There are [examples](configs/example.env) of .env files in the "configs" directory. By default, without changing the settings, the game server will be launched with [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets). You can start the kbe server with your assets just point in the .env file the directory of your assets. For more information see settings [described here](#configuration-file). Copy an example env file to the root directory and change it if you want set your custom settings.

```bash
cp configs/example.env .env
```

Build KBEngine. There are some already built kbe images on [Docker Hub](https://hub.docker.com/repository/registry-1.docker.io/shedu/kbe-compiled/), so building kbe might only take a few minutes (or few seconds if docker cache is used).

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
make clean
```

View `logs` from the console

```bash
make logs_console
```

Other operations

```bash
make help
```

To switch games between each other, you only need to stop the instance of the running game and ELK. Then change the configuration file, build the image (if not built) and run an instance of another game. If the image of another game exists, then all you need to do is stop the services, change the config for the new game, and start its services. There is no need to delete images of the old game. By keeping the docker images of the previous version of the game, you can switch and run different game instances very quickly (less than a minute).

Only one game and ELK instance can be running at a time.

```bash
make stop_elk
make stop_game

cp configs/<my config file>.env .env

make build_game # if the game image doesn't already exist
make build_elk # if ELK images don't already exist

make start_game
make start_elk # it can take some time to services up
make logs_dejavu
```

<a name="config"><h2>Configuration file</h2></a>

The configuration file should be placed in the project root and has the name ".env". There are some examples in the [examples](configs/example.env).

```bash
cp configs/kbe-v2.5.12-demo.env .env
```

Set the path to Assets in the KBE_ASSETS_PATH variable in the config (the ".env" file). The path to Assets must be an absolute path pointing to your assets folder on your host. This assets folder will be copied into the game image. If KBE_ASSETS_PATH value is "demo", the latest version of [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets) is loaded and used (these assets are suitable for use in kbengine client demos). For demo purpose you need just copy an example config file like in the above command.

![Settings](https://user-images.githubusercontent.com/6612371/212449370-fb23aa6b-bd4a-4233-a3d0-1868b3ba37ae.jpg)

#### Database build settings

* MYSQL_ROOT_PASSWORD - database root password
* MYSQL_DATABASE - database name
* MYSQL_USER - database user
* MYSQL_PASSWORD - database password

#### KBE build settings

* KBE_GIT_COMMIT - KBEngine will be compiled from the source code based on a git commit. The latest commit of the kbe repository will be use if the value of the variable is unset. Example: 7d379b9f
* KBE_USER_TAG - Mark the compiled kbengine image by this tag. E.g.: v2.5.12

#### Game assets settings

* KBE_ASSETS_PATH - The absolute path to the assets directory. If it has the "demo" value the [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets "The demo settings provided by KBEngine developers") will be used as Assets
* KBE_ASSETS_SHA - The commit of Assets
* KBE_ASSETS_VERSION - The version of Assets. This variable labels the finaly game image. It cannot be empty. Set any non-empty string if your project has no version.
* KBE_KBENGINE_XML_ARGS - With this field, you can change the values of the fields in kbengine.xml in the final image of the game (example: KBE_KBENGINE_XML_ARGS=root.dbmgr.account_system.account_registration.loginAutoCreate=true;root.whatever=123)

#### Global Settings

* GAME_NAME - Under each instance of the game there is a separate kbe environment. The name of the game is a unique identifier for kbe environments. It cannot be empty.

<a name="elk"><h2>KBEngine logging (Elasticsearch + Logstash + Kibana)</h2></a>

The Shedu project demonstrates the use of the ELK stack ([Elastic + Logstash + Kibana](https://www.elastic.co/what-is/)) to easily view KBEngine logs.

Implemented the ability to run a separate instance of ELK for each game. You can conveniently save game server logs in Elasticsearch and conveniently view them through Kibana or Dejavu (frontends for Elasticsearch) . The state (logs) is saved between switching ELK from different games. Thus, for debugging purposes, you can quickly switch between different versions of the game or engine without losing the log record.

ELK services are docker images. The state is stored in a named volume created for each game. Services are launched using docker-compose and at the start the containers are associated with the desired volume. Shedu implements a wrapper for general management and binding of game instances to ELK instances. The version used is ELK v8.5.3.

## Logging in KBEngine (brief overview)

At the engine level, the log4cxx library (log4j for C++) is used for logging. The default configuration files for log4j are located in the directory [kbe/res/server/log4cxx_properties_defaults](https://github.com/kbengine/kbengine/tree/master/kbe/res/server/log4cxx_properties_defaults). This directory contains a separate file for each component. The logging settings can be reloaded by defining custom log4j settings in the `res/server/log4cxx_properties` folder.

By default, logs are written to the `assets/logs` directory. If all KBEngine server components are located on the same host, all logs will be in this folder. By default, each component sends all logs to the Logger component (using the KBEngine message protocol). And already Logger writes the received logs to the `assets/logs` folder. The file name for log records has the following pattern: `logger_<compnent_name>`. Some of the critical logs (errors and warnings) are written by the components to the `assets/logs` folder under their own name (for example, "machine.log").

## General principle of operation of KBEngine + ELK for collecting logs

Before starting, you need to build the service images if they are not already built and then start the services (the `.env` config file is required).

```bash
make build_elk
make start_elk
```

The life cycles of game services and ELK services are independent. ELK will work without a running game; similarly with the game: the game is assembled, updated and works without ELK.

Operating procedure:

* KBEngine default settings remain unchanged (logs are still written to `logs`)
* The `logs` folder of the container is mounted in a separate volume created for the logs
* This volume is mounted to the container with Logstash
* Logstash collects all new records from the `logs` folder, normalizes them and sends them to Elasticsearch
* Elasticsearch stores documents (write log) in its own volume (the ES volume and the log volume are different volumes)
* To view the logs stored in Elasticsearch, you can use the web interfaces of Kibana or Dejavu services locally running in Docker

You can open web interfaces to view logs

```bash
make logs_kibana
make logs_dejavu
```

For documentation on using [Kibana](https://www.elastic.co/kibana/) or [Dejavu](https://github.com/appbaseio/dejavu) see official sites.

Logstash configuration settings are located in the `shedu/data/logstash` folder. To customize the logging fields, you can modify the [grok](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html) pattern ["LOG_MESSAGE"](data/logstash/kbe_patterns). It is convenient to combine customization of this pattern with logging game scripts using the python language ([logging module](https://docs.python.org/3/library/logging.html)). An example of setting up logging of game scripts using Python can be found [here](https://github.com/ve-i-uj/anu/blob/develop/scripts/server_common/sclog.py).

Stopping ELK services

```bash
make stop_elk
```

Cleaning up ELK services

```bash
make clean
```

<a name="normalize_entitiesxml"><h2>Assets normalization</h2></a>

KBEngine has a confusing logic for checking assets, plus the behavior of components running on the same host and on different hosts is different. There were problems with kbengine-demo-assets. Almost all entities have  GameObject in their interfaces. GameObject does not have "cell" and "base" methods, but has "cell" and "base" properties. Because of this, the engine, when running components in different containers based on kbengine-demo-assets, displayed errors on starting, such as

    ERROR baseapp01 1000 7001 [2023-06-07 05:15:27 522] - Space::createCellEntityInNewSpace: cannot find the cellapp script(Space)!
    S_ERR baseapp01 1000 7001 [2023-06-07 05:15:27 522] - Traceback (most recent call last):
    File "/opt/kbengine/assets/scripts/base/Space.py", line 24, in __init__
    self.spaceUTypeB = self.cellData["spaceUType"]
    S_ERR baseapp01 1000 7001 [2023-06-07 05:15:27 522] - AttributeError: 'Space' object has no attribute 'cellData'
    INFO baseapp01 1000 7001 [2023-06-07 05:15:27 522] - EntityApp::createEntity: new Space 2007

It turned out that the engine required that entities must specify `hasCell` in the entities.xml file. Since my goal was to work with the default kbengine-demo-assets from the developers, I added a script that normalizes the entities.xml file. The script, when building the game image, analyzes assets and modifies entities.xml, prescribing `hasCell`, `hasBase` to entities. But this led to the fact that almost all entities had `base` and `cell` components (hasBase=true and hasCell=true) due to GameObject in interfaces. The engine began to require, at startup, to implement modules for entities, for example, base/Monster or cell/Spaces. Then I added to the same normalizing script the addition of empty modules to such entities when building the image.

<a name="build"><h2>Build activity</h2></a>

![Build kbe](https://user-images.githubusercontent.com/6612371/212449373-9935364b-7144-4880-9144-e2b19a6fbb22.jpg)
![Build Assets](https://user-images.githubusercontent.com/6612371/212449374-f39cc7ad-2b50-4f22-804d-929be1c680c7.jpg)
