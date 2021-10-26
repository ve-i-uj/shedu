Shedu

The project builds, packages and starts kbengine and kbe environment in the docker containers.

The main goal of the project is to simplify kbengine deploy. It doesn't need to know how to build a C++ project or what library you need to install for. Moreover all kbe infrastructure (database, smtp server etc) can be built and started just in one command too. You can choose a kbe commit for your kbe build and easy link assets to the chosen kbe version. Change variables in "configs/example.env" and save the file like a new one with your configuration.


Start KBEngine + DB

```
cd <YOUR_REPO_DIR>
git clone https://github.com/ve-i-uj/shedu
cd shedu
make start_game config=configs/example.env
```

Full cleanup

```
make clean
```
