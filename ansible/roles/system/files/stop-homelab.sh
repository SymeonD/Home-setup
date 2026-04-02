#!/bin/bash
set -euo pipefail

echo "Stopping homelab services..."

kubectl scale deployment --all -n minecraft --replicas=0
kubectl scale deployment --all -n n8n --replicas=0
kubectl scale deployment --all -n nextcloud --replicas=0
kubectl scale deployment --all -n immich --replicas=0
kubectl scale deployment --all -n traefik --replicas=0

echo "Homelab services stopped."
