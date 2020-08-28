FROM debian:buster as builder

ARG CUTELYST_VERSION=v2.9.0
ARG VIRTLYST_VERSION=v1.2.0

RUN apt-get update \
    # Install build dependencies
    && apt-get install -y git cmake g++ qtbase5-dev libgrantlee5-dev pkg-config libvirt-dev qttools5-dev-tools \
    && cd /usr/local/src \
    # Build cutelyst
    && git -c http.sslVerify=false clone https://github.com/cutelyst/cutelyst.git \
    && cd cutelyst \
    && git checkout tags/$CUTELYST_VERSION \
    && mkdir build && cd build \
    && export QT_SELECT=qt5 \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DPLUGIN_VIEW_GRANTLEE=on \
    && make && make install \ 
    # Build virtlyst
    && cd /usr/local/src \
    && git -c http.sslVerify=false clone https://github.com/cutelyst/Virtlyst.git \
    && cd Virtlyst \
    && git checkout tags/$VIRTLYST_VERSION \
    && cmake . \
    && make

FROM debian:buster-slim
# Start with a clean image but keep compiled stuff
VOLUME /data
COPY --from=builder /usr/local /usr/local
WORKDIR /usr/local/src/Virtlyst
RUN apt-get update \
    # Install dependencies
    && apt-get install --no-install-recommends -y libqt5core5a libqt5network5 libqt5sql5-sqlite libqt5sql5 libqt5xml5 libvirt0 libgrantlee-templates5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && cp /usr/local/src/Virtlyst/src/libVirtlyst.so /usr/local/lib/x86_64-linux-gnu/ \
    # Fix ld library path
    && echo "/usr/local/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/usr-local.conf \
    && ldconfig 

COPY example-config.ini /data/config.ini 
CMD ["/usr/local/bin/cutelyst-wsgi2","--ini","/data/config.ini"]

