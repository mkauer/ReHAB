#!/bin/bash

# version: 10.10.19
############################################################

unset LD_LIBRARY_PATH

export YBIN=Linux
export YLIB=Linux
export YSCR=Linux
export YMACH=LINUX
export OPTS=" -O3 -m32"
export YOPTIOF=" -fno-automatic -finit-local-zero -Wno-globals -fno-globals"
export YOPTIOC=" -I/usr/X11R6/include"
export F77_COMP=g77
export N3AROOT=/unix/nemo2/n3/soft

export ROOTSYS=/unix/nemo2/misc/ROOT/5.22.00_slc4_x86_gcc34
export ROOT_BIN=${ROOTSYS}/bin
export ROOT_LIB=${ROOTSYS}/lib
export LD_LIBRARY_PATH=${ROOT_LIB}:${LD_LIBRARY_PATH}
export PATH=${ROOT_BIN}:${PATH}

export MYSQL_ROOT=/usr
export MYSQL_LIB=${MYSQL_ROOT}/lib/mysql
export MYSQL_INCL=${MYSQL_ROOT}/include/mysql
export LD_LIBRARY_PATH=${MYSQL_LIB}:${LD_LIBRARY_PATH}
export MYSQL_CFLAGS=$(mysql_config --cflags)
export MYSQL_LIBS=$(mysql_config --libs)
export LD_LIBRARY_PATH=${MYSQL_LIB}:${LD_LIBRARY_PATH}

export N3DB_ROOT=${N3AROOT}/N3Db
export LD_LIBRARY_PATH=${N3DB_ROOT}/lib:${LD_LIBRARY_PATH}

export NEMO_ROOT=${N3AROOT}/N3Nemos_10.09.27
export NEMO_BIN=${NEMO_ROOT}/analy/prog/bin.Linux
export PATH=${NEMO_BIN}:${PATH}

export R10SYS=${N3AROOT}/rootana
export PATH=${R10SYS}/utils:${PATH}
export LD_LIBRARY_PATH=${R10SYS}/utils/lib:${LD_LIBRARY_PATH}

export BBFTP_BIN=/unix/nemo2/misc/BBFTP/bbftp-client-3.2.0/bin
export PATH=${BBFTP_BIN}:${PATH}

export CLHEP_BASE_DIR=/unix/nemo2/misc/CLHEP/1.9.4.2_slc4_x86_gcc34
export LD_LIBRARY_PATH=${CLHEP_BASE_DIR}/lib:${LD_LIBRARY_PATH}

export CERN=/unix/nemo2/misc/CERNLIB
export CERN_LEVEL=2006b-g77
export CERN_ROOT=${CERN}/${CERN_LEVEL}
export CERNLIB_ROOT=${CERN_ROOT}
export CERN_PREFIX=${CERN_ROOT}
export CERN_BIN=${CERN_ROOT}/bin
export CERN_LIB=${CERN_ROOT}/lib
export CERN_INC=${CERN_ROOT}/include
export LD_LIBRARY_PATH=${CERN_LIB}:${LD_LIBRARY_PATH}
export PATH=${CERN_BIN}:${PATH}

