FROM debian:buster-slim as builder

ARG CUTELYST_VERSION=v2.9.0
ARG VIRTLYST_VERSION=v1.2.0

RUN apt-get update \
    # Install build dependencies
    && apt-get install -y git cmake g++ qtbase5-dev libgrantlee5-dev pkg-config libvirt-dev qttools5-dev-tools \
    && cd /usr/local/src \
    # Build cutelyst
    && git clone https://github.com/cutelyst/cutelyst.git \
    && cd cutelyst \
    && git checkout tags/$CUTELYST_VERSION \
    && mkdir build && cd build \
    && export QT_SELECT=qt5 \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DPLUGIN_VIEW_GRANTLEE=on \
    && make && make install \ 
    # Build virtlyst
    && cd /usr/local/src \
    && git clone https://github.com/cutelyst/Virtlyst.git \
    && cd Virtlyst \
    && git checkout tags/$VIRTLYST_VERSION \
    && cmake . \
    && make

FROM debian:buster-slim
# Start with a clean image but keep compiled stuff
COPY --from=builder /usr/local /usr/local
WORKDIR /usr/local/src/Virtlyst

RUN apt-get update \
    # Install dependencies
    && apt-get install -y libqt5core5a libqt5network5 libqt5sql5 libqt5xml5 libvirt0 libgrantlee-templates5 \
    && apt-get clean \
    # Copy lib to correct path
    && cp /usr/local/src/Virtlyst/src/Virtlyst*.so /usr/local/lib/x86_64-linux-gnu
    # Fix ld library path
    && echo "/usr/local/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/usr-local.conf \
    && ldconfig \
    # Prepare config file
    && cp example-config.ini config.ini \
    && sed -i -e 's/virtlyst\.sqlite/\/data\/virtlyst\.sqlite/g' config.ini \
    && sed -i -e 's/TemplatePath = \./TemplatePath = root\/src/g' config.ini

VOLUME /data
CMD ["/usr/local/bin/cutelyst-wsgi2","--ini","config.ini"]

