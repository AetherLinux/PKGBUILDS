#!/usr/bin/env bash

tp=$(curl -s 'https://archlinux.org/packages/?page=1&flagged=Flagged' |
    grep -o -m1 'Page 1 of [0-9]*' | rev | cut -f1 -d" ")

for pg in $(seq 1 "$tp"); do
    for x in $(curl -s "https://archlinux.org/packages/?page=$pg&flagged=Flagged" |
        rg -oe '/packages/[A-Za-z0-9\-_]*/(any|x86_64)/[A-Za-z0-9\-_]*' |
        xargs -n1 basename |
        sort -u); do
        echo "Cloning: $x"

        git clone --depth 1 https://github.com/archlinux/svntogit-community.git \
            -b packages/"$x" "$x" 2>/dev/null ||
            git clone --depth 1 https://github.com/archlinux/svntogit-packages.git \
                -b packages/"$x" "$x" 2>/dev/null

        if [ $? -eq 0 ]; then
            dir=$(ls "$x/repos/" | rg -oe '(extra-x86_64|core-x86_64|community-x86_64|extra-any|core-any|community-any)')
            mv "$(pwd)/$x/repos/$dir"/* "$(pwd)/$x"/
            rm -rf "$(pwd)/$x/repos" "$(pwd)/$x/trunk" "$(pwd)/$x/.git"
        fi
    done
done
