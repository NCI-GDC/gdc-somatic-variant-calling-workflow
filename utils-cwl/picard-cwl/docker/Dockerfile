FROM ubuntu:xenial-20161010

MAINTAINER Jeremiah H. Savage <jeremiahsavage@gmail.com>

RUN apt-get update \
    && apt-get install -y \
       openjdk-8-jre-headless \
       r-base \
       wget \
    && apt-get clean \
    && wget https://github.com/broadinstitute/picard/releases/download/2.10.1/picard.jar \
    && mv picard.jar /usr/local/bin/ \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
