#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Attribution Assurance License (AAL)
# Copyright © 2025 AERO Company (Olivier Flentge)
# This script automates building & pushing the Pumpkin image to GHCR.
# ----------------------------------------------------------------------------

set -euo pipefail

IMAGE_NAME="pumpkin"
REGISTRY="ghcr.io"
GH_USER="${GH_USER:-$(git config --get user.name || true)}"
TAG="${1:-latest}"

if [[ -z "${GH_USER}" ]]; then
  echo "[ERROR] Environment variable GH_USER is not set and could not be autodetected." >&2
  echo "        Export GH_USER=<github-username> and optionally GH_PAT=<token>." >&2
  exit 1
fi

FULL_IMAGE="${REGISTRY}/${GH_USER}/${IMAGE_NAME}:${TAG}"

# Login if token present and not yet logged in
if ! docker system info 2>/dev/null | grep -q "Username: ${GH_USER}"; then
  if [[ -z "${GH_PAT:-}" ]]; then
    echo "[WARN] Not logged in to ${REGISTRY} and GH_PAT not set; assuming you are already logged in via Docker Desktop." >&2
  else
    echo "[INFO] Logging in to ${REGISTRY} as ${GH_USER}" >&2
    echo -n "${GH_PAT}" | docker login ${REGISTRY} -u "${GH_USER}" --password-stdin
  fi
fi

echo "[INFO] Building image ${FULL_IMAGE}" >&2

docker build -t "${FULL_IMAGE}" -f "$(dirname "$0")/../Dockerfile" "$(dirname "$0")/.."

if [[ "${TAG}" != "latest" ]]; then
  docker tag "${FULL_IMAGE}" "${REGISTRY}/${GH_USER}/${IMAGE_NAME}:latest"
fi

echo "[INFO] Pushing ${FULL_IMAGE}" >&2
docker push "${FULL_IMAGE}"

if [[ "${TAG}" != "latest" ]]; then
  echo "[INFO] Pushing :latest tag"
  docker push "${REGISTRY}/${GH_USER}/${IMAGE_NAME}:latest"
fi

echo "[SUCCESS] Image pushed. In Pterodactyl, hit 'Rebuild Container' or restart the server to fetch the new layer." 