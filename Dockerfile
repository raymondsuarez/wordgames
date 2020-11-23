FROM balenalib/aarch64-alpine:3.12-build
LABEL io.balena.device-type="raspberrypi4-64"

WORKDIR /word_games

COPY . .
COPY templates templates
COPY static static
COPY static/css static/css
COPY static/js static/js
COPY static/js/vendor static/js/vendor

RUN apk add --update \
                less \
                py3-pip \
                nano \
                net-tools \
                ifupdown \
                usbutils \
                gnupg \
                raspberrypi \
                raspberrypi-libs \
                raspberrypi-dev \
           && rm -rf /var/cache/apk/*

RUN [ ! -d /.balena/messages ] && mkdir -p /.balena/messages; echo $'Here are a few details about this Docker image (For more information please visit https://www.balena.io/docs/reference/base-images/base-images/): \nArchitecture: ARM v8 \nOS: Alpine Linux 3.12 \nVariant: build variant \nDefault variable(s): UDEV=off \nExtra features: \n- Easy way to install packages with `install_packages <package-name>` command \n- Run anywhere with cross-build feature  (for ARM only) \n- Keep the container idling with `balena-idle` command \n- Show base image details with `balena-info` command' > /.balena/messages/image-info

RUN install_packages py3-pip

RUN pip install -r requirements.txt
RUN echo $'#!/bin/bash\nbalena-info\nbusybox ln -sf /bin/busybox /bin/sh\n/bin/sh "$@"' > /bin/sh-shim \
	&& chmod +x /bin/sh-shim \
	&& ln -f /bin/sh /bin/sh.real \
	&& ln -f /bin/sh-shim /bin/sh

EXPOSE 8003

ENTRYPOINT ["sh","./deploy.sh"]