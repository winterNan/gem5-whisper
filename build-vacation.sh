#!/bin/bash

# Setup scons to scons-2.1.0. Otherwise memcached will 
# be compiled using python3 which will incur problem

export PATH=$HOME/scons-2.1.0/bin:$PATH

# setup cmake to cmake-3.20.2. The default version won't do

export PATH=$HOME/cmake-3.20.2/bin:$PATH

# setup pkg-config PATH for Intel libfabric, which is locally installed in the home dir. 

export PKG_CONFIG_PATH=$HOME/libfabric-1.12.1/lib/pkgconfig:$PKG_CONFIG_PATH
export CPATH=$HOME/libfabric-1.12.1/include:$CPATH

#########################################################

### To run on Gem5, always set STATIC_BUILD="ON"
### This will fix all the static linked issues

STATIC_BUILD="ON"

#########################################################

if [[ " $STATIC_BUILD " =~ " ON " ]]; then

	### To compile static alps, change the following in 
	### $HOME/Benchmarks/whisper/mnemosyne-gcc/usermode/library/pmalloc/include/alps/src/CMakeLists.txt
	### From 
	### add_library(alps SHARED ${TMP_ALL_ALPS_SRC})
	### To 
	### add_library(alps STATIC ${TMP_ALL_ALPS_SRC})
	### Then re-run this script

	### Build lib alps

	cd "$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode/library/pmalloc/include/alps"

	if [ -d "build" ] 
	then
		rm -r "build"
	fi

	mkdir build
	cd build

	cmake .. -DTARGET_ARCH_MEM=CC-NUMA -DBUILD_SHARED_LIBS=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make

	### Build vacation

	cd "$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode"

	if [ -d "build/bench/stamp-kozy" ] 
	then
		rm -r "build/bench/stamp-kozy"
	fi

	scons --build-bench=stamp-kozy --static-link

elif [[ " $STATIC_BUILD " =~ " OFF " ]]; then

	### Build lib alps

	cd "$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode/library/pmalloc/include/alps"

	if [ -d "build" ] 
	then
		rm -r "build"
	fi

	mkdir build
	cd build

	cmake .. -DTARGET_ARCH_MEM=CC-NUMA -DBUILD_SHARED_LIBS=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make

	### Build vacation

	cd "$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode"

	if [ -d "build/bench/stamp-kozy" ] 
	then
		rm -r "build/bench/stamp-kozy"
	fi

	scons --build-bench=stamp-kozy 

else
	echo "Error occurs"
	exit -1
fi