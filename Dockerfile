FROM debian:9.2

LABEL maintainer "opsxcq@strm.sh | modified by axelcypher"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libasound2-dev \
    libvorbisidec-dev \
    libvorbis-dev \
    libflac-dev \
    alsa-utils \
    libavahi-client-dev \
    avahi-daemon \
    git \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /code
RUN git clone --recursive https://github.com/badaix/snapcast.git src && \
    cd src && \
    make && \
    make installserver && \
    make installclient

RUN git clone --recursive https://github.com/librespot-org/librespot.git src && \
    cd src && \
    cargo build --release && \
    mv librespot /usr/local/bin/librespot 
    

RUN git clone --recursive https://github.com/badaix/snapweb.git src && \
    cd src && \
    make && \
    mv -R dist /output/dist/


RUN useradd --system --uid 666 -M --shell /usr/sbin/nologin snapcast && \
    mkdir -p /home/snapcast/.config && \
    chown snapcast:snapcast -R /home
USER snapcast

EXPOSE 1704
EXPOSE 1780

VOLUME /data
WORKDIR /data

COPY main.sh /
ENTRYPOINT ["/main.sh"]
