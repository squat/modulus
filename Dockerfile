FROM debian:buster-slim
MAINTAINER Lucas Servén <lserven@gmail.com>
RUN apt-get update && apt-get install -y \
    bzip2 \
    curl \
    gdisk \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*
COPY modulus /opt/modulus/modulus
COPY nvidia/compile /opt/modulus/nvidia/compile
ENTRYPOINT ["/opt/modulus/modulus"]
