# build
FROM python:3.8-slim as build-stage

COPY requirements.txt /root/

RUN     apt-get update && \
        apt-get install -y --no-install-recommends wget curl unzip imagemagick \ 
        ffmpeg build-essential python3-dev python3-pip python3-twisted \ 
        libxml2-dev python3-lxml python3-requests

RUN 	pip3 install -r /root/requirements.txt

# deploy
FROM jrottenberg/ffmpeg:4.2-scratch AS ffmpeg

FROM python:3.8-slim

COPY --from=ffmpeg / /
COPY --from=build-stage /root/.cache/pip /root/.cache/pip
COPY --from=build-stage /root/requirements.txt /root

COPY --from=build-stage /usr/lib/x86_64-linux-gnu/*.so.* /usr/lib/x86_64-linux-gnu/
COPY --from=build-stage /lib/x86_64-linux-gnu/*.so.* /lib/x86_64-linux-gnu/

RUN apt-get update && \
	apt-get install -y tini wget curl fonts-ipafont git python3-dev python3-pip python3-setuptools task-spooler libxml2-dev libxslt1-dev gcc g++ build-essential cmake jq poppler-utils && \
	pip3 install --upgrade --force-reinstall pip setuptools wheel && \
	pip3 install -r /root/requirements.txt && \
	rm -rf /root/.cache/pip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV	COMMAND ""
ENV	KEYWORD ""
ENV	TESTMODE ""

WORKDIR /workspace
COPY start.sh /workspace
COPY scrapy.sh /workspace

ENTRYPOINT ["bash","start.sh"]
