#!/bin/bash
set -e # exit on error
set -u # stop on undeclared variable

PYQT=${1:-false}
CLEAN=${2:-no}

SIP=sip-4.13.3

if [ ! -d "$PYQT" ]; then
  echo "Usage: $0 PyQt4/PyQt3Supported/sources [clean]"
  exit 1
fi

PYQT=$(readlink -f $PYQT)
cd $(dirname $(readlink -f $0))/../

mkdir -p build
BUILD=$(readlink -f build)

mkdir -p downloads
pushd downloads
[ ! -e $SIP.tar.gz ] && wget -c http://www.riverbankcomputing.com/static/Downloads/sip4/$SIP.tar.gz
[ ! -d $SIP ] && tar zxf $SIP.tar.gz
pushd $SIP
python configure.py -b $BUILD -d $BUILD -e $BUILD -v $BUILD
if [ "$CLEAN" == "clean" ]; then
  make clean
fi
make
make install
popd
popd

pushd $PYQT
PYTHONPATH=$BUILD python configure.py -q /usr/bin/qmake-qt4 -c -j3 -b $BUILD -d $BUILD -p $BUILD -n $BUILD -s $BUILD -e QtGui -e Qt3Support --confirm-license
if [ "$CLEAN" == "clean" ]; then
  make clean
fi
make
make install
popd

PYTHONPATH=$BUILD python -c "from PyQt4.Qt import *; print [x for x in dir() if 'Q3' in x]"
