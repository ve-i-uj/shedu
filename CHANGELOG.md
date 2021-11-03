# Changelog

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
