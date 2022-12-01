#!/usr/bin/env bash

dir="$1"
echo "$2"
echo "dir: $dir"
pkglist_name=$(echo "$dir" | tr '-' '_')
echo "pkglist_name: $pkglist_name"
source "$2/pkglist"
old_pkgs="$pkglist_name[@]"
old_pkgs=("${!old_pkgs}")
echo "old: " "${old_pkgs[@]}"
source "$2/../$dir/PKGBUILD"
new_pkgs=("${pkgname[@]}")
new_pkgs=("${new_pkgs[@]/%/-${pkgver}-${pkgrel}-${arch}.pkg.tar.zst}")
echo "new:" "${new_pkgs[@]}"

if [ -z "${old_pkgs[@]}" ]; then
    new_pkgs_sigs=("${new_pkgs[@]/%/.sig}")
    echo -e "$pkglist_name=(""${new_pkgs[@]}"" ${new_pkgs_sigs[@]}"")" >>"$2/pkglist"
else
    for pkg in "${old_pkgs[@]}"; do
        echo "Removing: $pkg"
        rm -rf "$2/x86_64/$pkg"
    done
    new_pkgs_sigs=("${new_pkgs[@]/%/.sig}")
    sed -i "s|.*$pkglist_name=.*|$pkglist_name=(${new_pkgs[@]} ${new_pkgs_sigs[@]})|" "$2/pkglist"
fi
