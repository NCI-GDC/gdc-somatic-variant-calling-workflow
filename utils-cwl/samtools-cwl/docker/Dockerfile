FROM ubuntu:xenial-20161010

MAINTAINER Bill Wysocki <wwysoc2@uchicago.edu>

## Adapted from https://github.com/NCI-GDC/samtools_docker/blob/master/docker/Dockerfile

RUN apt-get update \
	&& apt-get install -y \
		bzip2 \
		gcc \
		libncurses-dev \
		make \
		wget \
		zlib1g-dev \
		libbz2-dev \
		liblzma-dev \
	&& apt-get clean \
	&& wget http://sourceforge.net/projects/samtools/files/samtools/1.1/samtools-1.1.tar.bz2 \
	&& tar xf samtools-1.1.tar.bz2 \
	&& cd samtools-1.1 \
	&& make \
	&& make install \
	&& cd - \
	&& rm -rf
