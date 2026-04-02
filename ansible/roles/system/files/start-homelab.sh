#!/bin/bash
set -euo pipefail

echo "Starting homelab services..."

kubectl scale deployment --all -n traefik --replicas=1
kubectl scale deployment --all -n immich --replicas=1
kubectl scale deployment --all -n nextcloud --replicas=1
kubectl scale deployment --all -n n8n --replicas=1
kubectl scale deployment --all -n minecraft --replicas=1

echo "Waiting for deployments to be ready..."
kubectl rollout status deployment --timeout=120s -n traefik
kubectl rollout status deployment --timeout=120s -n immich
kubectl rollout status deployment --timeout=120s -n nextcloud
kubectl rollout status deployment --timeout=120s -n n8n
kubectl rollout status deployment --timeout=120s -n minecraft

echo "Homelab services started."
