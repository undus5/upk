#!/bin/bash

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pdir=$(dirname ${self_dir})
ventoy_dir=${pdir}/apps/ventoy

cd ${ventoy_dir}
./Ventoy2Disk.sh "${@}"

