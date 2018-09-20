# qBittorrent and OpenVPN
FROM phusion/baseimage:0.11
MAINTAINER fryfrog@gmail.com

VOLUME /downloads
VOLUME /config

ENV DEBIAN_FRONTEND noninteractive

# Update packages and install software
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils openssl && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable && \
    apt-get install -y qbittorrent-nox openvpn curl moreutils net-tools dos2unix kmod iptables ipcalc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration and scripts
ADD root/ /root/
ADD qbittorrent/ /etc/qbittorrent/

RUN chmod +x /root/*.sh /etc/qbittorrent/*.init

# Expose ports and run
EXPOSE 8080
EXPOSE 8999
EXPOSE 8999/udp

# Start it all up
CMD ["/bin/bash", "/root/start.sh"]
