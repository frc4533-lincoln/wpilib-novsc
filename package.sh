#!/bin/sh

WPILIB_VERSION="2023.4.3"
WPILIB_BUILD_URL="https://github.com/wpilibsuite/allwpilib/releases/download/v${WPILIB_VERSION}/WPILib_Linux-${WPILIB_VERSION}.tar.gz"

if [ -e dist ]; then
  rm -rf ./dist/
fi

curl -sL "${WPILIB_BUILD_URL}" | \
tar -Oxzv "WPILib_Linux-${WPILIB_VERSION}/WPILib_Linux-${WPILIB_VERSION}-artifacts.tar.gz" | \
tar --one-top-level=wpilib-novsc-tmp --wildcards -xzv 'documentation/' 'maven/edu/wpi/first/' './roborio/'

for f in $(cat extract-list.txt); do
  unzip -o -d wpilib-novsc-tmp "wpilib-novsc-tmp/${f}"
done

#
# Dist tarball packaging

# Create dist directory structure
mkdir -p ./wpilib-novsc-athena/usr/lib/ ./wpilib-novsc-athena/usr/include/ \
  ./wpilib-novsc-toolchain/usr/bin/ ./wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/gcc/bin/ ./wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/gcc/libexec/ ./wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/roborio/bin/ ./wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/roborio/lib/ \
  ./wpilib-novsc-sysroot/usr/libexec/wpilib-novsc/roborio/sysroot/ ./ \
  ./wpilib-novsc-docs/cpp/ ./wpilib-novsc-docs/frc/

cd ./wpilib-novsc-tmp/

# Rename NI libs
# Move libraries into dist
mv ./linux/athena/shared/libvisa.so.* ./linux/athena/shared/libvisa.so
mv ./linux/athena/shared/libFRC_NetworkCommunication.so.* ./linux/athena/shared/libFRC_NetworkCommunication.so
mv ./linux/athena/shared/*.so ../wpilib-novsc-athena/usr/lib/

# Move headers into dist
mkdir ./frc-headers/
mv ./frc/ ./frc2/ ./wpi/ ./wpinet/ ./wpimath/ ./networktables/ \
  ./units/ ./unsupported/ ./uv/ ./gcem_incl/ ./drake/ ./Eigen/ \
  ./hal/ ./fmt/ ./gcem.hpp ./uv.h ./WPILibVersion.h ./ntcore* \
  ./cscore* ./FRC_NetworkCommunication/ ./visa/ ./frc-headers/
mv ./frc-headers/ ../wpilib-novsc-athena/usr/include/frc/

# Move documentation into dist
mv ./documentation/cpp/* ../wpilib-novsc-docs/cpp/
mv ./documentation/rtd/* ../wpilib-novsc-docs/frc/

# Generate wrappers for each gcc binary
# Move wrappers and binaries into dist
for f in ./roborio/bin/*; do
  # Move vanilla binary into dist
  mv ${f} ../wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/gcc/bin/
  # Generate a wrapper and write to dist
  printf '#!/bin/sh\n\nCOMPILER_PATH="$(pwd)/../libexec/wpilib-novsc/roborio/bin" ' > "../wpilib-novsc-toolchain/usr/bin/${f##./roborio/bin/}"
  printf "%s/../libexec/wpilib-novsc/gcc/bin/${f##./roborio/bin/}\n" '$(pwd)' >> "../wpilib-novsc-toolchain/usr/bin/${f##./roborio/bin/}"
done
mv ./roborio/libexec/* ../wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/gcc/libexec/
mv ./roborio/arm-nilrt-linux-gnueabi/bin/* ../wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/roborio/bin/
mv ./roborio/arm-nilrt-linux-gnueabi/lib/* ../wpilib-novsc-toolchain/usr/libexec/wpilib-novsc/roborio/lib/

# Remove debug info from roborio sysroot
# Move roborio sysroot into dist
rm -r ./roborio/arm-nilrt-linux-gnueabi/sysroot/lib/.debug/ \
  ./roborio/arm-nilrt-linux-gnueabi/sysroot/usr/lib/.debug/
mv ./roborio/arm-nilrt-linux-gnueabi/sysroot/* ../wpilib-novsc-sysroot/usr/libexec/wpilib-novsc/roborio/sysroot/

cd ../

# Pack and compress dist tarballs
for distdir in "wpilib-novsc-athena" "wpilib-novsc-toolchain" "wpilib-novsc-sysroot" "wpilib-novsc-docs"; do
  cat ./LICENSE.md ./ThirdPartyNotices.txt > ./${distdir}/LICENSE.txt
  tar -C ${distdir} -cvf "${distdir}.tar" .
  xz -9e "${distdir}.tar"
done

#
# Clean up

mkdir -p ./dist/
cp wpilib-novsc-*.tar.xz ./dist/
rm -rf "WPILib_Linux-${WPILIB_VERSION}.tar.gz" wpilib-novsc-*
