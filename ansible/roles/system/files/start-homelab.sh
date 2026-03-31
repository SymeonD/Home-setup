docker compose -f /opt/docker/traefik/docker-compose.yml up -d
docker compose -f /opt/docker/immich/docker-compose.yml up -d
docker compose -f /opt/docker/nextcloud/docker-compose.yml up -d
docker compose -f /opt/docker/minecraft/docker-compose.yml up -d
echo "✅ Homelab services started."