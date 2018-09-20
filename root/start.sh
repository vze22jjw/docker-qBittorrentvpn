#!/bin/bash

# Graceful shutdown, used by trapping SIGTERM
function graceful_shutdown {
  echo -n "Stopping qBitTorrent... "
  if /etc/qbittorrent/qbittorrent.init stop; then
    echo "done."
    exit 0
  else
    echo "failed."
    exit 1
  fi
}

# Trap SIGTERM for graceful exit
trap graceful_shutdown SIGTERM

# set user nobody to specified user id
export PUID=$(echo "${PUID}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${PUID}" ]]; then
  echo "[info] PUID defined as '${PUID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PUID not defined (via -e PUID), defaulting to '99'" | ts '%Y-%m-%d %H:%M:%.S'
  export PUID="99"
fi

usermod -o -u "${PUID}" nobody &>/dev/null

# set group nogroup to specified group id
export PGID=$(echo "${PGID}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${PGID}" ]]; then
  echo "[info] PGID defined as '${PGID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PGID not defined (via -e PGID), defaulting to '65534'" | ts '%Y-%m-%d %H:%M:%.S'
  export PGID="65534"
fi

groupmod -o -g "${PGID}" nogroup &>/dev/null

# set webui to specified port
export WEBUI_PORT=$(echo "${WEBUI_PORT}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ -n "${WEBUI_PORT}" ]]; then
  echo "[info] WEBUI_PORT defined as '${WEBUI_PORT}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] WEBUI_PORT not defined (via -e WEBUI_PORT), defaulting to '8080'" | ts '%Y-%m-%d %H:%M:%.S'
  export WEBUI_PORT="8080"
fi


# set incomming to specified port
export INCOMING_PORT=$(echo "${INCOMING_PORT}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ -n "${INCOMING_PORT}" ]]; then
  echo "[info] INCOMING_PORT defined as '${INCOMING_PORT}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] INCOMING_PORT not defined (via -e INCOMING_PORT), defaulting to '8999'" | ts '%Y-%m-%d %H:%M:%.S'
  export INCOMING_PORT="8999"
fi

# Start up the VPN
/root/start-openvpn.sh

# Start up qBitTorrent
/root/start-qbittorrent.sh

while true; do
  sleep 2
done
