#!/bin/sh

#Created by Halit ŞENARSLAN


CURRENT_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#--- Project Variables
PROJECT_ROOT_FOLDER="${CURRENT_DIR}"
PROJECT_NAME="[ProjectName]"
SCHEME="[SchemeToBuild]"
DERIVED_DATA="[DerivedDataFolder]"
#---


function createBuildDir() {
    mkdir $CURRENT_DIR/build
}

function buildForIphone() {
    echo "--Building For Device----------START-----------"
    xcodebuild clean build \
        -project $PROJECT_ROOT_FOLDER/$PROJECT_NAME.xcodeproj \
        -scheme $SCHEME \
        -configuration Release \
        -sdk iphoneos \
        -derivedDataPath $DERIVED_DATA \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    mkdir $CURRENT_DIR/build/devices
    cp -r $DERIVED_DATA/Build/Products/Release-iphoneos/$SCHEME.framework $CURRENT_DIR/build/devices
    echo "--Building For Device----------END-----------"
}

function buildForSimulator() {
    echo "--Building For Simulator----------START-----------"
    xcodebuild clean build \
        -project $PROJECT_ROOT_FOLDER/$PROJECT_NAME.xcodeproj \
        -scheme $SCHEME \
        -configuration Release \
        -sdk iphonesimulator \
        -derivedDataPath $DERIVED_DATA \
        EXCLUDED_ARCHS=arm64\
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    mkdir $CURRENT_DIR/build/simulator
    cp -r $DERIVED_DATA/Build/Products/Release-iphonesimulator/$SCHEME.framework $CURRENT_DIR/build/simulator
    #lipo -remove arm64 "$CURRENT_DIR/build/simulator/${PROJECT_NAME}.framework/$SCHEME" -output "$CURRENT_DIR/build/simulator/${PROJECT_NAME}.framework/$SCHEME"
    echo "--Building For Simulator----------END-----------"
}

function createUniversalBaseDirectory() {
    mkdir $CURRENT_DIR/build/universal
    cp -r $CURRENT_DIR/build/devices/$SCHEME.framework $CURRENT_DIR/build/universal/
}

function createUniversalLibrary() {
    lipo -create \
        $CURRENT_DIR/build/simulator/$SCHEME.framework/$SCHEME \
        $CURRENT_DIR/build/devices/$SCHEME.framework/$SCHEME \
        -output $CURRENT_DIR/build/universal/$SCHEME.framework/$SCHEME

    cp -r \
        $CURRENT_DIR/build/simulator/$SCHEME.framework/Modules/$SCHEME.swiftmodule/* \
        $CURRENT_DIR/build/universal/$SCHEME.framework/Modules/$SCHEME.swiftmodule/

        
    xcrun xcodebuild -create-xcframework \
        -framework $CURRENT_DIR/build/devices/$SCHEME.framework \
        -framework $CURRENT_DIR/build/simulator/$SCHEME.framework \
        -output $CURRENT_DIR/build/universal/${SCHEME}.xcframework
}

function executePipeline() {
    createBuildDir
    buildForIphone
    buildForSimulator
    createUniversalBaseDirectory
    createUniversalLibrary
}

executePipeline