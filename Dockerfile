FROM debian:buster-slim
MAINTAINER Lucas Servén <lserven@gmail.com>
RUN apt-get update && apt-get install -y \
    bzip2 \
    curl \
    gdisk \
    gnupg2 \
    kmod \
    pciutils \
    awscli \
    && rm -rf /var/lib/apt/lists/*
COPY modulus /opt/modulus/modulus
COPY nvidia/compile /opt/modulus/nvidia/compile
COPY nvidia/install /opt/modulus/nvidia/install
COPY wireguard/compile /opt/modulus/wireguard/compile
COPY wireguard/install /opt/modulus/wireguard/install
ENTRYPOINT ["/opt/modulus/modulus"]
