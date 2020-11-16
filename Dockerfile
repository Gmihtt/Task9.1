# Dockerfile
FROM ubuntu

RUN apt -y update && apt -y upgrade
RUN apt-get install -y curl
RUN curl -sSL https://get.haskellstack.org/ | sh

COPY . /usr/multi-layer

RUN cd usr/multi-layer && stack build

WORKDIR /usr/multi-layer
CMD ["stack", "exec", "multi-layer-exe"]