#!/bin/bash

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
installed_dir=$self_dir

${installed_dir}/bwrap.sh $installed_dir ~/Jts/tws
