Start KBEngine + DB

```
PROJECT_DIR=<YOUR_PROJECT_DIR>
cd $PROJECT_DIR
bash scripts/docker/build_kbe.sh
docker-compose --env-file configs/dev.env build
docker-compose --env-file configs/dev.env up --remove-orphans --force-recreate
```

Full cleanup

```
docker-compose --env-file configs/dev.env down -v
```

Restart

```
docker-compose --env-file configs/dev.env up --remove-orphans --force-recreate --build
```
