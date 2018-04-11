FROM quay.io/ncigdc/samtools:1.1

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev

ADD multi_mpileup.py /bin/

ENV multi_mpileup v1.1
