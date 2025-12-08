#!/bin/bash

VOLUME=/mnt/home/jovyan 

if [ ! -f $VOLUME ]; then
    sudo mkdir -p $VOLUME
    sudo chown $(id -u):$(id -g) -R $VOLUME
fi

sudo docker run -v $VOLUME:/home/jovyan -p 8888:8888 -it localhost/jupyterlab:eds-base-notebook_ubuntu-24.04-local 
