#!/bin/bash
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

# Set qBitTorrent WebUI port
if [ -n "${WEBUI_PORT}" ]; then
  webui_port_exist=$(grep -m 1 "WebUI\\\Port=${WEBUI_PORT}" /config/qBittorrent/config/qBittorrent.conf)
  if [[ -z "${webui_port_exist}" ]]; then
    webui_exist=$(grep -m 1 'WebUI\Port' /config/qBittorrent/config/qBittorrent.conf)
    if [[ -n "${webui_exist}" ]]; then
      # Get line number of WebUI Port
      LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' /config/qBittorrent/config/qBittorrent.conf | cut -d: -f 1)
      sed -i "${LINE_NUM}s@.*@WebUI\Port=${WEBUI_PORT}\n@" /config/qBittorrent/config/qBittorrent.conf
    else
      echo "WebUI\Port=${WEBUI_PORT}" >> /config/qBittorrent/config/qBittorrent.conf
    fi
  fi
fi
echo "[info] qBittorrent WebUI port: ${WEBUI_PORT}" | ts '%Y-%m-%d %H:%M:%.S'

# Set qBitTorrent incoming port
if [ -n "${INCOMING_PORT}" ]; then
  incoming_port_exist=$(grep -m 1 "Connection\\\PortRangeMin=${INCOMING_PORT}" /config/qBittorrent/config/qBittorrent.conf)
  if [[ -z "${incoming_port_exist}" ]]; then
    incoming_exist=$(grep -m 1 'Connection\PortRangeMin' /config/qBittorrent/config/qBittorrent.conf)
    if [[ -n "${incoming_exist}" ]]; then
      # Get line number of Incoming
      LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' /config/qBittorrent/config/qBittorrent.conf | cut -d: -f 1)
      sed -i "${LINE_NUM}s@.*@Connection\PortRangeMin=${INCOMING_PORT}\n@" /config/qBittorrent/config/qBittorrent.conf
    else
      echo "Connection\PortRangeMin=${INCOMING_PORT}" >> /config/qBittorrent/config/qBittorrent.conf
    fi
  fi
fi
echo "[info] qBittorrent incoming port: ${INCOMING_PORT}" | ts '%Y-%m-%d %H:%M:%.S'

echo "[info] Starting qBittorrent daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/qbittorrent/qbittorrent.init start

sleep 1
qbpid=$(pgrep -o -x qbittorrent-nox)
echo "[info] qBittorrent PID: ${qbpid}" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e "/proc/${qbpid}" ]; then
  if [[ -e /config/qBittorrent/data/logs/qbittorrent.log ]]; then
    chmod 664 /config/qBittorrent/data/logs/qbittorrent.log
  fi
  sleep infinity
else
  echo "qBittorrent failed to start!"
fi
