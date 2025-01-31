#!/bin/sh

# Color echo output (only to emphasize the stages in the build process)
export GREEN=$(tput setaf 2)
export RED=$(tput setaf 1)
export NC=$(tput sgr0)

if [[ "$QMSDEVDIR" == "" ]]; then
    echo "${RED}Please set QMSDEVDIR var to builddir (absolute path needed)${NC}"
    echo "${RED}... OR run 1st_QMS_start.sh${NC}"
    return
fi

if [[ "$BUILD_RELEASE_DIR" == "" ]]; then
    BUILD_RELEASE_DIR=$QMSDEVDIR/release
fi

SRC_OSX_DIR=$QMSDEVDIR/QMapShack/MacOSX

# Bundling QMapShack and QMapTool
echo "${GREEN}Bundle QMapShack ...${NC}"
mkdir $BUILD_RELEASE_DIR
cd $SRC_OSX_DIR
source ./bundle-qmapshack.sh
cd $SRC_OSX_DIR
source ./bundle-qmaptool.sh
echo "${GREEN}Find QMapShack.app and QMapTool.app in $BUILD_RELEASE_DIR${NC}"

# Codesign the apps (on arm64 mandatory):
echo "${GREEN}Signing app bundles${NC}"
codesign --force --deep --sign - $BUILD_RELEASE_DIR/QMapShack.app 
codesign --force --deep --sign - $BUILD_RELEASE_DIR/QMapShack.app/Contents/Tools/gdalbuildvrt
codesign --force --deep --sign - $BUILD_RELEASE_DIR/QMapTool.app
echo "${GREEN}QMapShack.app and QMapTool.app are signed${NC}"

echo "${RED}You can clean up build artifacts by running${NC}"
echo "${RED}sh $SRC_OSX_DIR/clean.sh clean${NC}"

cd $QMSDEVDIR
