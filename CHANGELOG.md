
# Changelog

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
