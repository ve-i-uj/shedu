KBE_ROOT=$HOME/kbengine
UBUNTU_ARCHIVE="http://ru.archive.ubuntu.com/ubuntu"

if ! $( grep -Fxq "$UBUNTU_ARCHIVE xenial main" /etc/apt/sources.list ); then
    echo "deb $UBUNTU_ARCHIVE xenial main" | sudo tee -a /etc/apt/sources.list
fi
if ! $( grep -Fxq "$UBUNTU_ARCHIVE xenial universe" /etc/apt/sources.list ); then
    echo "deb $UBUNTU_ARCHIVE xenial universe" | sudo tee -a /etc/apt/sources.list
fi

sudo apt update
sudo apt install gcc g++ g++-5 gcc-5 make git autoconf libtool \
    libmysqlclient-dev -y

git clone https://github.com/kbengine/kbengine.git "$KBE_ROOT"
cd "$KBE_ROOT/kbe/src/"

export CC=gcc-5
export CXX=g++-5
make

echo "KBEngine executable files are located at \"$KBE_ROOT/kbe/bin/server\""

echo "Done ($(basename $0))"
