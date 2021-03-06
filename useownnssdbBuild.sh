#!/usr/bin/env bash

# Modified build.sh to use own nssdb from latest build

cwd=$(cd $(dirname $0); pwd -P)

# Usage info
show_help()
{
    cat "$cwd/help.txt"
    exit
}

makefile2use=Makefile
buildroot=${HOME}/buildjss
target4make=run

#
# Parse command line arguments.
#

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -h | --help )
    shift; show_help;
    ;;
  -s | --slf4jpath )
    shift; slf4jpath=$1
    ;;
  -m | --makefile2use)
    shift; target4make=$1
    ;;
  -t | --target4make)
    shift; target4make=$1
    ;;
  -b | --buildroot )
    buildroot=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

if [[ ! -f /etc/os-release ]] ; then
    echo 'File "/etc/os-release" is not there, aborting.'
    exit
fi

isFedora=`grep fedora /etc/os-release`
isDebian=`grep debian /etc/os-release`
isOpenSUSE=`grep opensuse /etc/os-release`


if [[ "${isOpenSUSE}" != '' ]]; then
    echo "openSUSE build"
    slf4jpath=/usr/share/java/slf4j/api.jar:/usr/share/java/slf4j/slf4j-jdk14.jar
elif [[ "${isDebian}" != '' ]]; then
    echo "Debian build"
    slf4jpath=/usr/share/java/slf4j-api.jar:/usr/share/java/jdk14.jar
elif [[ "${isFedora}" != '' ]]; then
    echo "Fedora build"
    slf4jpath=/usr/share/java/slf4j/api.jar:/usr/share/java/slf4j/jdk14.jar
else
    echo "Unsupported distribution"
    exit
fi

# Now make

removeNssdb=
if [[ "$target4make" == "run" ]]; then 
    removeNssdb=remove-nssdb 
fi
BUILDROOT=${buildroot} \
SLF4JPATH=${slf4jpath} \
TARGET4MAKE=${target4make} \
make -f ${makefile2use} ${target4make}

