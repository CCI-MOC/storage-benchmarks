FROM ubuntu:24.04

RUN apt update &&  \
    apt install -y git bc mpich python3 python3-pip wget

## IOR
RUN wget https://github.com/hpc/ior/releases/download/4.0.0/ior-4.0.0.tar.gz && \
    tar -xzvf ior-4.0.0.tar.gz && \
    cd ior-4.0.0 && \
    ./configure && \
    make && \
    make install

## ML Perf Storage
RUN git clone -b v1.0 --recurse-submodules https://github.com/mlcommons/storage.git

WORKDIR /storage

RUN pip3 install --break-system-packages -r dlio_benchmark/requirements.txt

COPY entrypoint.sh /storage/entrypoint.sh

RUN chgrp -R 0 /storage && \
    chmod -R g+rwX /storage

ENTRYPOINT ["./entrypoint.sh"]
