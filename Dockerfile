FROM alpine:3.7
MAINTAINER Lucas Servén <lserven@gmail.com>
RUN apk add --no-cache bash curl gnupg gptfdisk
COPY modulus /opt/modulus/modulus
COPY nvidia/compile /opt/modulus/nvidia/compile
ENTRYPOINT ["/opt/modulus/modulus"]
