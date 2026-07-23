#!/bin/bash

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
channel=beta
src=${metapkg_dir}/../brave-origin/brave-origin.sh
[[ -x "${src}" ]] && source ${src}

