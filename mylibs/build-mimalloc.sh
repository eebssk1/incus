#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
version=3.7.0
commit=1ed67b5156a763441d2ec3c20221a7b3cd866129
sha256=a207a0802234ff9d21e7511eee52375e6299fa2ac7b25eb4ce26b579a7735c8c
work="$root/tmp/mimalloc-$version"
archive="$work/commit.tar.gz"
source="$work/mimalloc-$commit"
build="$work/build"

mkdir -p "$work/compiler-tmp"
export TMPDIR="$work/compiler-tmp"
if [ ! -f "$archive" ]; then
    curl --fail --location --retry 2 --output "$archive" \
        "https://github.com/microsoft/mimalloc/archive/$commit.tar.gz"
fi
printf '%s  %s\n' "$sha256" "$archive" | sha256sum --check
tar -xzf "$archive" -C "$work"

# Use upstream's architecture/SIMD preset and default security level.
cmake -S "$source" -B "$build" -G Ninja \
    -DCMAKE_C_COMPILER="${CC:-gcc}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DMI_BUILD_STATIC=ON \
    -DMI_BUILD_SHARED=OFF \
    -DMI_BUILD_OBJECT=OFF \
    -DMI_BUILD_TESTS=ON \
    -DMI_USE_CXX=OFF \
    -DMI_OVERRIDE=ON \
    -DMI_STATS=OFF \
    -DMI_PROFILE=OFF \
    -DMI_TLS_MODEL=LOCAL_DYNAMIC \
    -DMI_SECURE=DEFAULT \
    -DMI_OPT_ARCH=ON \
    -DMI_OPT_SIMD=ON
cmake --build "$build" --parallel "${JOBS:-4}" \
    --target mimalloc-static mimalloc-test-api mimalloc-test-api-fill
ctest --test-dir "$build" --output-on-failure -R '^test-api(-fill)?$'

cp "$build/libmimalloc.a" "$root/mylibs/libmimalloc.a"
sha256sum "$root/mylibs/libmimalloc.a"
