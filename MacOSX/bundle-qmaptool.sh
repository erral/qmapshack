#!/bin/sh

# Color echo output (only to emphasize the stages in the build process)
export GREEN=$(tput setaf 2)
export RED=$(tput setaf 1)
export NC=$(tput sgr0)

echo "${GREEN}Bundling QMapTool.app${NC}"

if [[ "$QMSDEVDIR" == "" ]]; then
    echo "${RED}Please set QMSDEVDIR var to builddir (absolute path needed)${NC}"
    echo "${RED}... OR run 1st_QMS_start.sh${NC}"
    return
fi

if [[ "$BUILD_RELEASE_DIR" == "" ]]; then
    BUILD_RELEASE_DIR=$QMSDEVDIR/release
fi

set -a
APP_NAME=QMapTool
set +a

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/bundle-env-path.sh
source $DIR/bundle-common-func.sh


function linkToQMapShack {
	# link to QMapShack application bundle
    cd $BUILD_RELEASE_DIR
    ln -s ../../QMapShack.app/Contents/Frameworks $BUILD_BUNDLE_FRW_DIR
    ln -s ../../QMapShack.app/Contents/PlugIns $BUILD_BUNDLE_PLUGIN_DIR
    ln -s ../../QMapShack.app/Contents/Tools/ $BUILD_BUNDLE_RES_BIN_DIR
    ln -s ../../QMapShack.app/Contents/lib/ $BUILD_BUNDLE_EXTLIB_DIR
    ln -s ../../../QMapShack.app/Contents/Resources/gdal $BUILD_BUNDLE_RES_GDAL_DIR
    ln -s ../../../QMapShack.app/Contents/Resources/proj $BUILD_BUNDLE_RES_PROJ_DIR

    #ln -s ../../../QMapShack.app/Contents/Resources/translations $BUILD_BUNDLE_RES_QM_DIR
    cd ..
}

function copyAdditionalLibraries {
    cp -v    $HOMEBREW_PREFIX/lib/libgeos*.dylib $BUILD_BUNDLE_EXTLIB_DIR
    # cp -v    $GDAL_DIR/* $BUILD_BUNDLE_FRW_DIR
}

function copyExternalHelpFiles_QMT {
    cp -v $HELP_QMT_DIR/QMTHelp.qch $BUILD_BUNDLE_RES_HELP_DIR
    cp -v $HELP_QMT_DIR/QMTHelp.qhc $BUILD_BUNDLE_RES_HELP_DIR
}


function removeDuplicatedQtLibs {
    rm -rf $BUILD_BUNDLE_FRW_DIR
    rm -rf $BUILD_BUNDLE_PLUGIN_DIR
}


if [[ "$1" == "" ]]; then
    echo "---extract version -----------------"
    extractVersion
    readRevisionHash
    echo "---build bundle --------------------"
    buildAppStructure
    extendAppStructure
    echo "---replace version string ----------"
    updateInfoPlist
    echo "---qt deploy tool ------------------"
    qtDeploy
    echo "---copy libraries ------------------"
    copyAdditionalLibraries
    echo "---copy external files -------------"
    copyQtTrqnslations
    copyExternalFiles
    copyExternalHelpFiles_QMT
    echo "---adjust linking ------------------"
    adjustLinking
    echo "---external tools ------------------"
    copyExtTools
    adjustLinkingExtTools
    printLinkingExtTools
    echo "------------------------------------"
fi
