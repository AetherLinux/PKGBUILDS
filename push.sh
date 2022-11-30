#!/usr/bin/env bash

dir="$1"
echo $2
echo "$dir"
pkglist_name=$(echo $dir | tr '-' '_')
source "$2/pkglist"
old_pkgs=("${pkglist_name[@]}")
source "$2/../$dir/PKGBUILD"
new_pkgs=("${pkgname[@]}")
new_pkgs=("${new_pkgs[@]/%/-${pkgver}-${pkgrel}-${arch}.pkg.tar.zst}")

if [ -z "$old_pkgs" ]; then
    echo -e "$pkglist_name=(${new_pkgs[@]})" >>"$2/pkglist"
else
    for pkg in "${old_pkgs[@]}"; do
        echo "Removing: $pkg"
        rm -rf "$2/x86_64/$pkg"
    done
    new_pkgs_sigs=("${new_pkgs[@]/%/.sig}")
    sed -i "s|.*$pkglist_name=.*|$pkglist_name=(${new_pkgs[@]} ${new_pkgs_sigs[@]})|" "$2/pkglist"
fi
