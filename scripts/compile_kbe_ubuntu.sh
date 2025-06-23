KBE_ROOT=$HOME/kbengine
UBUNTU_ARCHIVE="http://ru.archive.ubuntu.com/ubuntu"

apt update
apt install gnupg -y
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32

if ! $( grep -Fxq "$UBUNTU_ARCHIVE xenial main" /etc/apt/sources.list ); then
    echo "deb $UBUNTU_ARCHIVE xenial main" | tee -a /etc/apt/sources.list
fi
if ! $( grep -Fxq "$UBUNTU_ARCHIVE xenial universe" /etc/apt/sources.list ); then
    echo "deb $UBUNTU_ARCHIVE xenial universe" | tee -a /etc/apt/sources.list
fi

apt update
apt install gcc g++ g++-5 gcc-5 make git autoconf libtool \
    libmysqlclient-dev -y

git clone https://github.com/kbengine/kbengine.git "$KBE_ROOT"
cd "$KBE_ROOT/kbe/src/"

export CC=gcc-5
export CXX=g++-5
make

echo "KBEngine executable files are located at \"$KBE_ROOT/kbe/bin/server\""

echo "Done ($(basename $0))"
