#!/usr/bin/env bash

set -e

pushd "${0%/*}" &>/dev/null

# force english warning/error messages
export LC_ALL="C"

# check if we are on a supported host
PLATFORM=$(uname -s)
case $PLATFORM in
     Linux|Darwin|*BSD)
        ;;
     *)
        echo "this script is unix only for now" >&2
        exit 1
        ;;
esac

# prefer clang when CXX/CC are not set
if [[ $0 == *clang* ]]; then
    [[ $CC != *clang* ]] && export CC=clang
    [[ $CC != *clang++* ]] && export CXX=clang++
elif [[ $0 == *gcc* ]]; then
    [[ $CC != *gcc* ]] && export CC=gcc
    ([ -z "$CXX" ] || [[ $(basename $CXX) != g++* ]]) && export CXX=g++
elif [[ $0 == *sysc* ]]; then
    true # don't do anything
fi

# optimize for host architecture
export CFLAGS+=" -march=native"
export CXXFLAGS+=" -march=native"

SANITIZERS=0

# sanitizers
if [ -n "$SANITIZE" ]; then
    ASAN=1
    UBSAN=1
fi

[ -n "$ASAN" ] && SANFLAGS+=" -fsanitize=address"
[ -n "$TSAN" ] && SANFLAGS+=" -fsanitize=thread"
[ -n "$UBSAN" ] && SANFLAGS+=" -fsanitize=undefined -fno-sanitize=function"

if [ -n "$SANFLAGS" ]; then
    export OPTIMIZE=0
    export DEBUG=3

    export CXXFLAGS+=" $SANFLAGS"
    export CFLAGS+=" $SANFLAGS"

    if [[ $CXX != *clang* ]]; then
        # assume it's gcc
        CXXFLAGS+=" -fpic -pie"
        CFLAGS+=" -fpic -pie"
        export USESTATICLIBS=0
        export GLIBCCOMPAT=0
    fi
fi

# append WCCXXFLAGS to CXXFLAGS
[ -n "$WCCXXFLAGS" ] && CXXFLAGS+=" $WCCXXFLAGS"

# exit on error
set -e

# export library paths
if [ -n "$WCLIBDIR" ]; then
    export CPLUS_INCLUDE_PATH="$WCLIBDIR/include:$CPLUS_INCLUDE_PATH"
    export LIBRARY_PATH="$WCLIBDIR/lib:$LIBRARY_PATH"
fi

# use lto?
if [ -z "$LTO" ]; then
    if [[ $0 == *lto.sh ]]; then
        LTO=1
    else
        LTO=0
    fi
    export LTO
fi

# build
./build/build.sh $@

# install
if [ -n "$WCSDL1INSTALLDIR" ]; then
    WCINSTALLDIR=$WCSDL1INSTALLDIR
fi

if [ -n "$WCINSTALLDIR" ]; then
    if [ -e "$WCINSTALLDIR" -a ! -d "$WCINSTALLDIR" ]; then
        echo "install dir: $WCINSTALLDIR exists but is not a directory" >&2
        exit 1
    fi

    if [ $PLATFORM == "Darwin" ]; then
        # Assume Sauerbraten.app
        mkdir -p $WCINSTALLDIR/Contents/gamedata/{packages,data,doc,plugins}
        cp -p wclient "$WCINSTALLDIR/Contents/MacOS/sauerbraten_u"
        cp -p plugins/*.dylib "$WCINSTALLDIR/Contents/gamedata/plugins/"
        cp -pr ../data/* "$WCINSTALLDIR/Contents/gamedata/data"
        cp -pr ../packages/* "$WCINSTALLDIR/Contents/gamedata/packages"
        cp -pr ../doc/* "$WCINSTALLDIR/Contents/gamedata/doc"
    else
        mkdir -p $WCINSTALLDIR/{bin_unix,packages,data,doc,plugins}
        cp -p sauer_client "$WCINSTALLDIR/bin_unix/"
        cp -p plugins/*.so "$WCINSTALLDIR/plugins/"
        cp -pr ../data/* "$WCINSTALLDIR/data/"
        cp -pr ../packages/* "$WCINSTALLDIR/packages/"
        cp -pr ../doc/* "$WCINSTALLDIR/doc/"
    fi
fi
