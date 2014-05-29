#!/bin/sh

#Create by Kingxl 
#http://itjoy.org
#Builds versions of the VideoLAN x264 for armv7 ,armv7s and arm64
#Combines the three libraries into a single one
#Make sure you have installed: Xcode/Preferences/Downloads/Components/Command Line Tools
#

#Lib install dir.
DEST=install


#This is decided by your SDK version.
SDK_VERSION="7.1"

#Archs
ARCHS="armv7 armv7s arm64"

DEVPATH=/Applications/XCode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDK_VERSION}.sdk
#DEVPATH=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDK_VERSION}.sdk

#Clone x264
git clone git://git.videolan.org/x264.git x264

cd x264

export CC=`xcodebuild -find clang`

for ARCH in $ARCHS; do
    
    echo "Building $ARCH ......"

    ./configure \
    --host=arm-apple-darwin \
    --sysroot=$DEVPATH \
    --prefix=$DEST/$ARCH \
    --extra-cflags="-arch $ARCH" \
    --extra-ldflags="-L$DEVPATH/usr/lib/system -arch $ARCH" \
    --enable-pic \
    --enable-static \
    --disable-asm

    make && make install && make clean

    echo "Installed: $DEST/$ARCH"

done

echo "Combining library ......"
BUILD_LIBS="libx264.a"
OUTPUT_DIR="iPhoneOS"

cd install
mkdir $OUTPUT_DIR
mkdir $OUTPUT_DIR/lib
mkdir $OUTPUT_DIR/include


LIPO_CREATE=""

for ARCH in $ARCHS; do
    LIPO_CREATE="$LIPO_CREATE $ARCH/lib/$BUILD_LIBS "
done

lipo -create $LIPO_CREATE -output $OUTPUT_DIR/lib/$BUILD_LIBS
cp -f $ARCH/include/*.* $OUTPUT_DIR/include/

echo "************************************************************"
lipo -i $OUTPUT_DIR/lib/$BUILD_LIBS
echo "************************************************************"

echo "OK, merge done!"


