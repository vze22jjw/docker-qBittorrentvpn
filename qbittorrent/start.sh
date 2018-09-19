#!/bin/bash
PUID=$(echo "${PUID}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
export PUID

if [[ ! -z "${PUID}" ]]; then
  echo "[info] PUID defined as '${PUID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PUID not defined (via -e PUID), defaulting to '99'" | ts '%Y-%m-%d %H:%M:%.S'
  export PUID="99"
fi

# set user nobody to specified user id (non unique)
usermod -o -u "${PUID}" nobody &>/dev/null

PGID=$(echo "${PGID}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
export PGID

if [[ ! -z "${PGID}" ]]; then
  echo "[info] PGID defined as '${PGID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PGID not defined (via -e PGID), defaulting to '100'" | ts '%Y-%m-%d %H:%M:%.S'
  export PGID="65534"
fi

# set group users to specified group id (non unique)
groupmod -o -g "${PGID}" users &>/dev/null

if [[ ! -e /config/qBittorrent ]]; then
  mkdir -p /config/qBittorrent/config/
  chown -R "${PUID}":"${PGID}" /config/qBittorrent
else
  chown -R "${PUID}":"${PGID}" /config/qBittorrent
fi

if [[ ! -e /config/qBittorrent/config/qBittorrent.conf ]]; then
  cp /etc/qbittorrent/qBittorrent.conf /config/qBittorrent/config/qBittorrent.conf
  chmod 644 /config/qBittorrent/config/qBittorrent.conf
fi

# Set qBittorrent WebUI and Incoming ports
if [ ! -z "${WEBUI_PORT}" ]; then
  webui_port_exist=$(grep -m 1 "WebUI\Port=${WEBUI_PORT}" /config/qBittorrent/config/qBittorrent.conf)
  if [[ -z "${webui_port_exist}" ]]; then
    webui_exist=$(grep -m 1 'WebUI\Port' /config/qBittorrent/config/qBittorrent.conf)
    if [[ ! -z "${webui_exist}" ]]; then
      # Get line number of WebUI Port
      LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' /config/qBittorrent/config/qBittorrent.conf | cut -d: -f 1)
      sed -i "${LINE_NUM}s@.*@WebUI\Port=${WEBUI_PORT}\n@" /config/qBittorrent/config/qBittorrent.conf
    else
      echo "WebUI\Port=${WEBUI_PORT}" >> /config/qBittorrent/config/qBittorrent.conf
    fi
  fi
fi

if [ ! -z "${INCOMING_PORT}" ]; then
  incoming_port_exist=$(grep -m 1 "Connection\PortRangeMin=${INCOMING_PORT}" /config/qBittorrent/config/qBittorrent.conf)
  if [[ -z "${incoming_port_exist}" ]]; then
    incoming_exist=$(grep -m 1 'Connection\PortRangeMin' /config/qBittorrent/config/qBittorrent.conf)
    if [[ ! -z "${incoming_exist}" ]]; then
      # Get line number of Incoming
      LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' /config/qBittorrent/config/qBittorrent.conf | cut -d: -f 1)
      sed -i "${LINE_NUM}s@.*@Connection\PortRangeMin=${INCOMING_PORT}\n@" /config/qBittorrent/config/qBittorrent.conf
    else
      echo "Connection\PortRangeMin=${INCOMING_PORT}" >> /config/qBittorrent/config/qBittorrent.conf
    fi
  fi
fi

echo "[info] Starting qBittorrent daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/qbittorrent/qbittorrent.init start &
chmod -R 755 /config/qBittorrent

sleep 1
qbpid=$(pgrep -o -x qbittorrent-nox) 
echo "[info] qBittorrent PID: $qbpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e "/proc/${qbpid}" ]; then
  if [[ -e /config/qBittorrent/data/logs/qbittorrent.log ]]; then
    chmod 775 /config/qBittorrent/data/logs/qbittorrent.log
  fi
  sleep infinity
else
  echo "qBittorrent failed to start!"
fi
