#!/usr/bin/env bash

# Step1: Get fresh list of flagged packages from ArchLinux website
tp=$(curl -s 'https://archlinux.org/packages/?page=1&flagged=Flagged' |
    grep -o -m1 'Page 1 of [0-9]*' | rev | cut -f1 -d" ")
touch "temp.txt"
for pg in $(seq 1 "$tp"); do
    for x in $(curl -s "https://archlinux.org/packages/?page=$pg&flagged=Flagged" |
        rg -oe '/packages/[A-Za-z0-9\-_]*/(any|x86_64)/[A-Za-z0-9\-_]*' |
        xargs -n1 basename |
        sort -u); do
        echo "$x" >>temp.txt
    done
done

# Step2: Remove packages that aren't flagged on ArchLinux repos anymore
for d in */; do
    match=0
    dir="$(basename $d)"
    while IFS= read -r pkg; do
        if [ "$pkg" = "$dir" ]; then
            match=1
            echo "Found: $dir"
            break
        fi
    done <"temp.txt"
    if [ "$match" -eq "0" ]; then
        echo "Removing: $dir"
        rm -rf "$(pwd)/$dir"
    fi
done

# Step3: Add newly flagged packages
while IFS= read -r x; do
    if [ -d "$(pwd)/$x" ]; then
        echo "Skip: $x"
    else
        echo "Cloning: $x"
        git clone --depth 1 https://github.com/archlinux/svntogit-community.git \
            -b packages/"$x" "$x" 2>/dev/null ||
            git clone --depth 1 https://github.com/archlinux/svntogit-packages.git \
                -b packages/"$x" "$x" 2>/dev/null
        if [ $? -eq 0 ]; then
            dir=$(ls "$x/repos/" | rg -oe '(extra-x86_64|core-x86_64|community-x86_64|multilib-x86_64|extra-any|core-any|community-any|multilib-any)')
            mv "$(pwd)/$x/repos/$dir"/* "$(pwd)/$x"/
            rm -rf "$(pwd)/$x/repos" "$(pwd)/$x/trunk" "$(pwd)/$x/.git"
        fi
    fi
done <"temp.txt"

# Step4: Remove derps
rm -rf "temp.txt"
