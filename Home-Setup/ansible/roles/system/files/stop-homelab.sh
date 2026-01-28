docker compose -f /opt/docker/traefik/docker-compose.yml down
docker compose -f /opt/docker/immich/docker-compose.yml down
docker compose -f /opt/docker/nextcloud/docker-compose.yml down
echo "✅ Homelab services stopped."