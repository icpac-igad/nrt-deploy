docker-compose build

CURRENT_UID=$(id -u) docker-compose up -d --force-recreate
