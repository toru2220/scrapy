# build
FROM python:3.8-slim as build-stage

COPY requirements.txt /root/

RUN     apt-get update && \
        apt-get install -y --no-install-recommends wget curl unzip imagemagick ffmpeg && \
        apt-get install -y --no-install-recommends python3-dev python3-pip python-twisted && \
        apt-get install -y --no-install-recommends build-essential && \
        apt-get install -y --no-install-recommends libxml2-dev python-lxml python-requests

RUN 	pip3 install -r /root/requirements.txt

# deploy
FROM python:3.8-slim

## �r���h�p�C���[�W����Python���W���[�����r���h�����ۂ̃L���b�V���𗘗p����
COPY --from=build-stage /root/.cache/pip /root/.cache/pip
COPY --from=build-stage /root/requirements.txt /root
## Python���W���[���Ŏg�p���郉�C�u�������R�s�[
COPY --from=build-stage /usr/lib/x86_64-linux-gnu/*.so.* /usr/lib/x86_64-linux-gnu/
COPY --from=build-stage /lib/x86_64-linux-gnu/*.so.* /lib/x86_64-linux-gnu/

### �p�b�P�[�W�̃A�b�v�f�[�g��Python���W���[���̃C���X�g�[��
RUN apt-get update && \
	pip3 install -r /root/requirements.txt && \
	rm -rf /root/.cache/pip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
