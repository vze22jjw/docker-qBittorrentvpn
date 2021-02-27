# qBittorrent and OpenVPN
#
# Version 1.8

FROM ubuntu:18.04
LABEL "creator"="MarkusMcNugen"
LABEL "updated_by"="vze22jjw"

VOLUME /downloads
VOLUME /config

ENV DEBIAN_FRONTEND noninteractive

RUN usermod -u 99 nobody

# Update packages and install software
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils openssl \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:qbittorrent-team/qbittorrent-stable \
    && apt-get update && apt-get install -y \
        qbittorrent-nox \
        openvpn \
        curl \
        moreutils \
        net-tools \
        dos2unix \
        grep \
        kmod \
        iputils-ping \
        iptables \
        ipcalc \
        unrar \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration and scripts
ADD openvpn/ /etc/openvpn/
ADD qbittorrent/ /etc/qbittorrent/

RUN chmod +x /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh

# Expose ports and run
EXPOSE 8080
EXPOSE 8999
EXPOSE 8999/udp

# Ping Google DNS and check reply address
HEALTHCHECK --interval=5m --start-period=3m \
    CMD /bin/bash /config/openvpn/health_check.sh || exit 1

CMD ["/bin/bash", "/etc/openvpn/start.sh"]
