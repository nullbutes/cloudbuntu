FROM tsl0922/musl-cross
RUN git clone --depth=1 https://github.com/tsl0922/ttyd.git /ttyd \
    && cd /ttyd && env BUILD_TARGET=$BUILD_TARGET WITH_SSL=$WITH_SSL ./scripts/cross-build.sh

FROM ubuntu:latest
COPY --from=0 /ttyd/build/ttyd /usr/bin/ttyd

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /sbin/tini
RUN chmod +x /sbin/tini

RUN apt-get update; apt-get install -y --no-install-recommends \
	python3 \
	python3-setuptools \
	python3-pip \
	zip \
	unzip \
	p7zip-full \
	wget \
	nano \
	detox \
	tmux \
        curl \
        net-tools \
	php \
	git \
	htop \
        && apt-get autoclean \
        && apt-get autoremove \
        && pip3 install pyinstaller \
        && rm -rf /var/lib/apt/lists/*
    
    
ADD ./mc /app/mc
RUN chmod +x /app/mc && mv /app/mc /usr/local/bin/

ENV LOGIN_USER admin
ENV LOGIN_PASSWORD admin

ENTRYPOINT ["/sbin/tini", "--"]
#CMD ["ttyd", "bash"]
CMD ttyd --port $PORT --uid 0 --credential $LOGIN_USER:$LOGIN_PASSWORD bash
