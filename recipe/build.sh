#!/bin/bash

set -e

# hotfix: cmake can't find shapelib
_shapelib_pc=$PREFIX/lib/pkgconfig/shapelib.pc
if [[ -f $_shapelib_pc ]]; then
    _shapelib_pc=
else
    mkdir -p $(dirname $_shapelib_pc)
    echo "prefix=$PREFIX" > $_shapelib_pc
    cat <<'EOF' >> $PREFIX/lib/pkgconfig/shapelib.pc
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
datarootdir=${prefix}/share
datadir=${datarootdir}
includedir=${prefix}/include

Name: shapelib
Description: C API for processing ESRI Shapefiles
Version: 1.5.0
Libs: -L${libdir} -lshp
Cflags: -I${includedir}
EOF
fi

# fix absolute install path
sed -i.bak 's#"/Applications"#"${CMAKE_INSTALL_PREFIX}/Applications"#' loch/CMakeLists.txt

_builddir="build"
_sourcedir="$PWD"

cmake \
    -B "${_builddir}" \
    -S "${_sourcedir}" \
    -DBUILD_THBOOK=OFF \
    -DUSE_BUNDLED_FMT=OFF \
    -DUSE_BUNDLED_CATCH2=OFF \
    -DUSE_BUNDLED_SHAPELIB=OFF \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

cmake --build $_builddir -t therion loch
cmake --build $_builddir -t install

mkdir -p "${PREFIX}/etc"

cp \
    "${_sourcedir}/therion.ini" \
    "${_sourcedir}/xtherion/xtherion.ini" \
    "${PREFIX}/etc"

if [[ -n $_shapelib_pc ]]; then
    rm $_shapelib_pc
fi

if [[ ! -f $PREFIX/bin/loch ]]; then
    ln -vs ../Applications/loch.app/Contents/MacOS/loch $PREFIX/bin/
fi
