set -x
set -e
ROOTDIR=$(pwd)

# Clean out the build-repo and copy all custom packages
rm -rf vyos-build
git clone http://github.com/vyos/vyos-build vyos-build

# Patch to build-linux-firmware.sh
patch -t -u vyos-build/packages/linux-kernel/build-linux-firmware.sh < patches/0000_build-linux-firmware.sh.patch

# Patch to build-kernel.sh
patch -t -u vyos-build/packages/linux-kernel/build-kernel.sh < patches/0001_build-kernel.sh.patch

#KERNEL_BRANCH_NAME=v$(sed -n -e 's/^kernel_version = "\(.*\)"$/\1/p' vyos-build/data/defaults.toml)
KERNEL_BRANCH_NAME=rpi-$(sed -n -e 's/^kernel_version = "\([^.]\+\.[^.]\+\)\..\+"$/\1/p' vyos-build/data/defaults.toml).y
#KERNEL_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
KERNEL_REPO=https://github.com/raspberrypi/linux
FW_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git

cd vyos-build/packages/linux-kernel/

echo "Build kernel for pi (${KERNEL_BRANCH_NAME})"
git clone -b ${KERNEL_BRANCH_NAME} ${KERNEL_REPO}
./build-kernel.sh
git clone ${FW_REPO}
./build-linux-firmware.sh
git clone https://github.com/accel-ppp/accel-ppp.git
./build-accel-ppp.sh

cd ${ROOTDIR}
mkdir -p build
find vyos-build/packages/linux-kernel/ -type f | grep '\.deb$' | xargs -I {} cp {} build/
