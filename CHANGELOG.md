# Changelog

## [0.9.6] - 2023-05-13

### Changed
- Elastic geoip processor was disabled because Kibana cannot connect to Elastic

## [0.9.5] - 2023-02-01

### Added
- MariaDB health check and game start based on it
- An initial log file in the "logs" directory to view logs without running game
- The updated assets log4j settings to write logs to a separate dir for each game
- Log records in the ES index have the "game_name" field
- Exporting Kibana search settings before the log page is open

### Changed
- ELK and game compose projects were split
- The deployment diagram was updated
- The example configs were renamed
- The deploy scripts were moved to the common scripts directory

### Fixed
- Fixed: the assets repository didn't checkout to the defined commit

## [0.9.4] - 2023-01-21

### Fixed
- The kbe js plugin in a git submodule was not updated in the Dockerfile

## [0.9.3] - 2023-01-21

### Added
- A new config for the kbe server compatible with the Cocos2D-JS demo client
- A new Dockerfile for building of the cocos demo client
- Make rule for starting the kbe Cocos2D-JS demo

## [0.9.2] - 2023-01-21

### Added
- The configuration file for the source code with LGPL license (v1.1.8)

### Changed
- Machine ports and Interfaces telnet port were opened

### Fixed
- The variables from the .env file are not exported to the Makefile

## [0.9.1] - 2023-01-16

### Added
- Tests for building work flow were added
- Using cache of github responses

### Changed
- Checking ELK bash commands was moved in the Makefile (instead of the bash scripts)
- Using docker-compose with two config files to stop and clean artifacts

### Fixed
- The project is compatible with docker-compose version 1.25.0
- The "./configure" script was add the executable flag
- Minor fixes for the docker installation scripts

## [0.9.0] - 2023-01-14

### Added

- MVP of KBEngine + [ELK Stack](https://www.elastic.co/what-is/elk-stack) for kbe logging was added
- Web interfaces (Kibana and Dejavu) for log viewing

### Changed

- Kbe docker volumes and nets have the names based on $GAME_UNIQUE_NAME
- The build logic was moved to the Makefile, the unusing scripts were removed
- The scripts are used the log.sh lib
- The check_config.sh script checks all values are valid
- Makefile overrides some variables
- The status script was updated
- Debug makefile targets moved to the separate file
- the README file has more detail info about the project
- Some optimization to reuse docker cache

## [0.8.1] - 2022-09-25

### Changed

- The telnet CellApp ports and the DB port were exposed
- The "game" prefix or suffix in the make targets was deleted
- Executable mode for all bash scripts was added

## [0.8.0] - 2022-08-08

### Added

- A new setting variable "KBE_ASSETS_SHA" was added to the config file. You can build the game based on the assets git commit
- Two example configs were added to the project

## [0.7.0] - 2022-08-07

### Changed

- The shedu/.env settings file is mandatory
- Shedu settings in the assets are located in .env file

## [0.6.1] - 2022-08-06

### Added

- A new script for compiling KBEngine on Ubuntu was added

### Fixed

- Default kbe db settings were using. It was fixed

## [0.6.0] - 2022-07-30

### Changed

- The script building the assets image was updated: changed the order of image layers
- Added prefix --kbe to parameter names in bash scripts
- Make build of a kbengine image is using a new build script

### Added

- New scripts to build and to push the compiled kbe image on the docker hub were added
- A new script building the pre-assets image was added
- Force building of the kbengine without cache was added ("build_force" make rule)

## [0.5.1] - 2022-07-25

### Fixed

- The "start_game.sh" script cannot find the built kbe demo image. It was fixed.

## [0.5.0] - 2022-07-23

### Added

- Added a new script "configure" to install dependencies
- The build_assets.sh can download kbe assets demo

### Fixed

- The rule "make logs" was fixed: there was no game image name to attach to the container.

## [0.4.0] - 2021-11-06

### Added

- Added a new script to check logs of the game.

## [0.3.0] - 2021-11-03

### Added

- Added a new script to check the game container is running.
- Added a new script to tail logs of the game.

## [0.2.0] - 2021-11-03

### Added

- Added a new script to go into the running game container.

### Changed

- The game start and stop were split up two separated scripts.

## [0.1.0] - 2021-10-26

### Added

- Added makefile to manage the project.
- Added scripts: 1) to list project images 2) to request the latest commit sha of the kbengine repository 3) check a configuration file

### Changed

- Docker-compose only starts the game, all images are built by pure docker.
- An example configuration file was renamed to "example.env"

### Fixed

- No "mariadb-devel" library in the final image. It was added.
