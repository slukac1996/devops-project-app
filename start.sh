#!/bin/bash
set -e
NET=ticketing-net

podman run -d --network $NET --name postgres \
	-e POSTGRES_USER=ticketing_user \
	-e POSTGRES_PASSWORD=change_me_local \
	-e POSTGRES_DB=ticketing \
	-v ./infra/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql:Z \
	-v postgres-data:/var/lib/postgresql/data \
	docker.io/library/postgres:16
	
podman run -d --network $NET --name redis \
docker.io/library/redis:7

echo "Waiting for postgres..."
sleep 8

podman run -d --network $NET --name api --env-file .env -p 8080:8080 \
localhost/ticketing-api:dev

podman run -d --network $NET --name worker --env-file .env \
localhost/ticketing-worker:dev

podman run -d --network $NET --name frontend --env-file .env -p 3000:3000 \
localhost/ticketing-frontend:dev

echo "Svi pet containera radi"

