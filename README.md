![Logo](https://github.com/ve-i-uj/shedu/blob/develop/doc/pictures/shedu-640-320-pixelated.bmp?raw=true)

Shedu - Easy deploy of a KBEngine cluster

# Overview

The project builds, packages and starts [KBEngine](https://github.com/kbengine/kbengine "An open source MMOG server engine") and kbe environment in the docker containers.

The main goal of the project is to simplify kbengine deploy. It doesn't need to know how to build a C++ project or what library you need to install for. Moreover all kbe infrastructure (database, smtp server etc) can be built and started just in one command too. You can choose a kbe commit for your kbe build and easy link assets to the chosen kbe version. Change variables in "configs/example.env" and save the file like a new one with your configuration.

# Glossary

* Host - the server running docker
* Shedu - this project. A utility that deploys a KBEngine cluster to docker and interacts with this cluster

* KBEngine - server game engine in C++
* assets - game logic in Python + user server settings
* Game - KBEngine + assets

* Engine image - a docker image containing only built KBEngine
* Game image - a docker image containing KBEngine + assets

# Deploy

Download the project

```bash
git clone https://github.com/ve-i-uj/shedu
cd shedu
```

For the project to work, you need to install [Docker](https://docs.docker.com/desktop/install/linux-install/) and [Docker-compose](https://docs.docker.com/compose/install/) if they are not installed. You can install them according to their official documentation or [at your own risk] install them using the scripts that come with this project. If both Docker and Docker-compose exists on the host, you can skip this step.

```bash
bash scripts/prepare/install_docker.sh
bash scripts/prepare/install_latest_compose.sh
```

Install Dependencies

```bash
./configure
```

The project reads the settings from the ".env" file located in the root directory. There are example of .env files in the "configs" directory. By default, without changing the settings, the game server will be launched with [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets). You can start the kbe server with your assets just point in the .env file the directory of your assets. For more information see settings [described here](#configuration-file). Copy an example env file to the root directory and change it if you want set your custom settings.

```bash
cp configs/example.env .env
```

Build KBEngine. There are several already built kbe images on [Docker Hub](https://hub.docker.com/repository/registry-1.docker.io/shedu/kbe-compiled/), so building a kbe might only take a few minutes.

```bash
make build_kbe
```

Build the game

```bash
make build_game
```

Launch the game

```bash
make start
```

View logs from the console

```bash
make logs
```

Other operations

```bash
make help
```

# Configuration file

The configuration file should be placed in the project root and has the name ".env". Set the path to the assets folder to the [KBE_ASSETS_PATH](#configuration-file) variable in the config. The path to the assets should be an absolute path that points to your assets folder on your host. This assets folder will be copied to the game image. The default value for this variable is the empty string. In this case the latest version of [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets) will be downloaded and be used (these assets are suitable for use in kbengine client demos)

#### KBE build settings

* MYSQL_ROOT_PASSWORD - db root password
* MYSQL_DATABASE - database name
* MYSQL_USER - user
* MYSQL_PASSWORD - password

#### KBE build settings

* KBE_GIT_COMMIT - KBEngine will be compiled from the source code based on a git commit. The latest commit of the kbe repository will be use if the value of the variable is unset. Example: 7d379b9f
* KBE_USER_TAG - Mark the compiled kbengine image by this tag. E.g.: v2.5.12

#### Game assets settings

* KBE_ASSETS_PATH - The absolute path to the assets directory. If it has the "demo" value the [kbengine_demos_assets](https://github.com/kbengine/kbengine_demos_assets "The demo settings provided by KBEngine developers") will be used as an assets
* KBE_ASSETS_SHA - The commit of the assets
* KBE_ASSETS_VERSION - The version of the assets. This variable labels the finaly game image. It cannot be empty. Set any non-empty string if your project has no version.

# Deployment artifacts
![alt text](https://github.com/ve-i-uj/shedu/blob/develop/doc/pictures/depoyment_artefacts.bmp?raw=true "Deployment artifacts")
