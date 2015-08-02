#!/bin/bash

# Hints:
# http://boost.2283326.n4.nabble.com/how-to-build-boost-with-bzip2-in-non-standard-location-td2661155.html
# http://www.gentoo.org/proj/en/base/amd64/howtos/?part=1&chap=3
# http://www.boost.org/doc/libs/1_55_0/doc/html/bbv2/reference.html

# Hints for OSX:
# http://stackoverflow.com/questions/20108407/how-do-i-compile-boost-for-os-x-64b-platforms-with-stdlibc

set -x -e
 
if [ "$(uname)" == "Darwin" ]; then
    MACOSX_VERSION_MIN=10.8
    CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
    LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN} "
    LINKFLAGS="${LINKFLAGS} -stdlib=libc++"

    ./bootstrap.sh \
        --prefix="${PREFIX}/" \
        | tee bootstrap.log 2>&1

    ./b2 \
        variant=release \
        address-model=64 \
        architecture=x86 \
        threading=multi \
        link=shared \
        toolset=clang \
        cxxflags="${CXXFLAGS}" \
        linkflags="${LINKFLAGS}" \
        -j"$(sysctl -n hw.ncpu)" \
        install | tee b2.log 2>&1
fi

if [ "$(uname)" == "Linux" ]; then
    ./bootstrap.sh \
        --prefix="${PREFIX}" \
        --with-python="${PYTHON}" \
        --with-python-root="${PREFIX} : ${PREFIX}/include/python${PY_VER}m ${PREFIX}/include/python${PY_VER}" \
        --with-icu="${PREFIX}" \
        | tee bootstrap.log 2>&1

    ./b2 -q -d0 \
        variant=release \
        address-model="${ARCH}" \
        architecture=x86 \
        debug-symbols=off \
        threading=multi \
        runtime-link=shared \
        link=shared,static \
        toolset=gcc \
        python="${PY_VER}" \
        cflags="-O3 -I${PREFIX}/include" \
        cxxflags="-O3 -I${PREFIX}/include" \
        linkflags="-L${PREFIX}/lib" \
        --layout=system \
        -j"${CPU_COUNT}" \
        install | tee b2.log 2>&1
fi
