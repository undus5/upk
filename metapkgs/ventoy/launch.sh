#!/bin/bash

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
installed_dir=$self_dir

cd $installed_dir
./VentoyGUI.x86_64
