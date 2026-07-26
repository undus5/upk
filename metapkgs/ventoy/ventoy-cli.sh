#!/bin/bash

ventoy_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))

cd ${ventoy_dir}
./Ventoy2Disk.sh "${@}"
