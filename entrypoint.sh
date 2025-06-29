#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Attribution Assurance License (AAL)
# Copyright © 2025 AERO Company (Olivier Flentge)
# See LICENSE file for full text.
# ----------------------------------------------------------------------------

set -euo pipefail

# Colors
ORANGE='\033[38;5;208m'
RESET='\033[0m'

# ASCII banner + attribution (mandatory per AAL)
cat <<"EOF"
${ORANGE}

           ______ _____   ____  
     /\   |  ____|  __ \ / __ \ 
    /  \  | |__  | |__) | |  | |
   / /\ \ |  __| |  _  /| |  | |
  / ____ \| |____| | \ \| |__| |
 /_/    \_\______|_|  \_\\____/ 
                                
${RESET}
Powered by AERO Company – https://aero.nu
EOF

CONFIG_FILE="${CONFIG_FILE:-config/pumpkin.toml}"

# Config-directory garanderen
mkdir -p "$(dirname "${CONFIG_FILE}")"

# Functie om TOML-sleutel te vervangen of toe te voegen
set_config() {
  local key="$1" value="$2"
  if grep -q "^${key}\s*=\s*" "${CONFIG_FILE}" 2>/dev/null; then
    sed -i "s/^${key}\s*=\s*.*/${key} = ${value}/" "${CONFIG_FILE}"
  else
    echo "${key} = ${value}" >> "${CONFIG_FILE}"
  fi
}

# Pterodactyl variabelen injecteren (indien gezet)
[ -n "${SERVER_PORT:-}" ] && set_config "server-port" "${SERVER_PORT}"
[ -n "${MAX_PLAYERS:-}" ] && set_config "max-players" "${MAX_PLAYERS}"
[ -n "${MOTD:-}" ] && set_config "motd" "\"${MOTD}\""

exec pumpkin --config "${CONFIG_FILE}" 