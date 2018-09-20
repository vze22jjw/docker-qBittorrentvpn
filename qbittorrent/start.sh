#!/bin/bash
CONF_FILE="/config/qBittorrent/config/qBittorrent.conf"

if [[ ! -e /config/qBittorrent ]]; then
  mkdir -p /config/qBittorrent/config/
  chown -R "${PUID}":"${PGID}" /config/qBittorrent
else
  chown -R "${PUID}":"${PGID}" /config/qBittorrent
fi

if [[ ! -e "${CONF_FILE}" ]]; then
  cp /etc/qbittorrent/qBittorrent.conf "${CONF_FILE}"
  chmod 644 "${CONF_FILE}"
fi

# Set qBitTorrent WebUI port
echo "[info] qBittorrent WebUI port: ${WEBUI_PORT}" | ts '%Y-%m-%d %H:%M:%.S'
# Is the WEBUI_PORT variable set?
if [[ -n "${WEBUI_PORT}" ]]; then
  # Is the webui port already set correctly?
  if ! grep -q -m 1 "WebUI\\\Port=${WEBUI_PORT}" "${CONF_FILE}"; then
    # Is the webui port config option in the file?
    if grep -q -m 1 'WebUI\Port' "${CONF_FILE}"; then
      # Get line number of WebUI Port
      LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' "${CONF_FILE}" | cut -d: -f 1)
      sed -i "${LINE_NUM}s@.*@WebUI\Port=${WEBUI_PORT}\n@" "${CONF_FILE}"
      echo "[info] Modified existing WebUI Port in qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
    else
      echo "WebUI\Port=${WEBUI_PORT}" >> "${CONF_FILE}"
      echo "[info] Added WebUI Port to qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
    fi
  fi
fi

# Set qBitTorrent incoming port
echo "[info] qBittorrent incoming port: ${INCOMING_PORT}" | ts '%Y-%m-%d %H:%M:%.S'

# Is the INCOMING_PORT set?
if [[ -n "${INCOMING_PORT}" ]]; then
  # Is the incoming port set correctly?
  if ! grep -q -m 1 "Connection\\\PortRangeMin=${INCOMING_PORT}" "${CONF_FILE}"; then
    # Is incoming port config option in the file?
    if grep -q -m 1 'Connection\PortRangeMin' "${CONF_FILE}"; then
      # Get line number of Incoming
      LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' "${CONF_FILE}" | cut -d: -f 1)
      sed -i "${LINE_NUM}s@.*@Connection\PortRangeMin=${INCOMING_PORT}\n@" "${CONF_FILE}"
      echo "[info] Modified existing PortRangeMin in qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
    else
      echo "Connection\PortRangeMin=${INCOMING_PORT}" >> "${CONF_FILE}"
      echo "[info] Added PortRangeMin to qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
    fi
  fi
fi

echo "[info] Starting qBittorrent daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/etc/qbittorrent/qbittorrent.init start

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
