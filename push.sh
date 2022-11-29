#!/usr/bin/env bash

dir="$1"
echo $2
echo "$dir"
old_pkg=$(grep -E -A1 "\[${dir}\]" "$2/pkglist" | tail -n1)
echo "$old_pkg"
source "$2/../$dir/PKGBUILD"
new_pkg="$pkgname-$pkgver-$pkgrel-$arch.pkg.tar.zst"
echo "$new_pkg"
if [ -z "$old_pkg" ]; then
	echo -e "[$dir]\n$new_pkg\n" >>"$2/pkglist"
else
	rm -rf "$2/x86_64/$old_pkg"
	sed -i "s|$old_pkg|$new_pkg|" "$2/pkglist"
fi
