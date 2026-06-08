#!/bin/bash

errf() { printf "${@}\n" >&2; exit 1; }
test_cmd() { command -v $1 &>/dev/null; }

test_cmd foot && term=foot
[[ -z "$term" ]] && test_cmd alacritty && term=alacritty
[[ -z "$term" ]] && errf "==> terminal emulator not found"

if [[ -d $1 ]]; then
    wkdir=$1; shift
    cmd="$@"
    if [[ "$term" == "foot" ]]; then
        foot -D "$wkdir" $cmd
    elif [[ "$term" == "alacritty" ]]; then
        alacritty --working-directory "$wkdir" -e $cmd
    fi
elif [[ -n "$@" ]]; then
    exec=$1; shift
    args="$@"
    if [[ "$term" == "foot" ]]; then
        foot $exec "$args"
    elif [[ "$term" == "alacritty" ]]; then
        alacritty -e $exec "$args"
    fi
else
    if [[ "$term" == "foot" ]]; then
        foot
    elif [[ "$term" == "alacritty" ]]; then
        alacritty
    fi
fi

