FROM ubuntu:20.04


RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN mkdir /VizQue && \
  mkdir -p /VizQue/vizque &&\
  mkdir -p /VizQue/react-app

WORKDIR /VizQue/vizque
COPY ./vizque/vizque.nim /VizQue/vizque

RUN DEBIAN_FRONTEND=noninteractive apt-get update &&\
  apt-get upgrade -y && \
  rm -rf /var/lib/apt/lists/*


RUN apt update && apt upgrade -y
#タイムゾーン選択の回避
RUN apt-get install -y tzdata

#必要なモジュールをインストール
RUN apt install -y git curl build-essential wget vim


ENV NVM_DIR /usr/local/.nvm
ENV NODE_VERSION 10.23.2

# Install nvm
RUN git clone https://github.com/creationix/nvm.git $NVM_DIR && \
  cd $NVM_DIR && \
  git checkout `git describe --abbrev=0 --tags`

# Install default version of Node.js
RUN source $NVM_DIR/nvm.sh && \
  nvm install $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  nvm use default && npm i -g  npm@5.10.0


# Add nvm.sh to .bashrc for startup...
RUN echo "source ${NVM_DIR}/nvm.sh" > $HOME/.bashrc && \
  source $HOME/.bashrc

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules


# Set the path.
ENV PATH  $NVM_DIR/v$NODE_VERSION/bin:$PATH


#ソースコードから最新版のNimをビルドする
RUN mkdir /nim_bild
WORKDIR /nim_bild
RUN wget https://nim-lang.org/download/nim-1.4.2.tar.xz
RUN tar -Jxvf nim-1.4.2.tar.xz
WORKDIR /nim_bild/nim-1.4.2
RUN sh build.sh && \
  bin/nim c koch && \
  ./koch boot -d:release && \
  ./koch tools

WORKDIR /VizQue/vizque
ENV PATH  /nim_bild/nim-1.4.2/bin:$PATH







WORKDIR /VizQue
SHELL [ "bash", "-c" ]





# WORKDIR /VizQue/react-app
WORKDIR /VizQue/vizque


EXPOSE 5555



