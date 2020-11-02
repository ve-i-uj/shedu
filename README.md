```
PROJECT_DIR=<YOUR_PROJECT_DIR>
cd $PROJECT_DIR
bash scripts/docker/build_kbe.sh
bash scripts/docker/build_assets.sh
docker-compose --env-file configs/dev.env up --remove-orphans --force-recreate
```
