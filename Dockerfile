# --------------------------------------------------------------------------------
# Docker configuration for P4D
# --------------------------------------------------------------------------------

FROM ubuntu:focal

LABEL vendor="Dimensional Wave Ltd"
LABEL maintainer="Daniel McAssey (dan@glokon.me)"

# --------------------------------------------------------------------------------
# Docker Build
# --------------------------------------------------------------------------------

ARG P4D_VERSION="2024.2-2697822"
ARG SWARM_VERSION="2024.6-2710109"

# Update Ubuntu and add Perforce Package Source
# Do in-page search over https://package.perforce.com/apt/ubuntu/dists/focal/release/binary-amd64/Packages
# for both "Package: helix-p4d" and "Package: helix-swarm-triggers".
RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends -y wget gnupg2 ca-certificates && \
    wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - && \
    echo "deb http://package.perforce.com/apt/ubuntu focal release" > /etc/apt/sources.list.d/perforce.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y helix-p4d=${P4D_VERSION}~focal helix-swarm-triggers=${SWARM_VERSION}~focal && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*.

COPY scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# --------------------------------------------------------------------------------
# Docker ENVIRONMENT
# --------------------------------------------------------------------------------

# Default Environment
ARG NAME=perforce-server
ARG P4NAME=master
ARG P4TCP=1666
ARG P4USER=admin
ARG P4PASSWD=pass12349ers
ARG P4CASE=-C0
ARG P4CHARSET=utf8

# Dynamic Environment
ENV NAME=$NAME \
  P4NAME=$P4NAME \
  P4TCP=$P4TCP \
  P4PORT=$P4TCP \
  P4USER=$P4USER \
  P4PASSWD=$P4PASSWD \
  P4CASE=$P4CASE \
  P4CHARSET=$P4CHARSET \
  JNL_PREFIX=$P4NAME

# Base Environment
ENV P4HOME=/p4

# Derived Environment
ENV P4ROOT=$P4HOME/root \
  P4DEPOTS=$P4HOME/depots \
  P4CKP=$P4HOME/checkpoints

# Expose Perforce; TCP port and volumes
EXPOSE $P4TCP
VOLUME $P4HOME

# --------------------------------------------------------------------------------
# Docker RUN
# --------------------------------------------------------------------------------

ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK \
  --interval=2m \
  --timeout=10s \
  CMD p4 info -s > /dev/null || exit 1
