#!/bin/sh

# *** UNCOMMENT TO OVERRIDE AUTODETECTED NI VERSION ***
# Version format scheme: major.minor.yyyymmdd[-r]
# - where yyyy: year, mm: month, dd: day, r: optional release suffix
# NI_VERSION="2.3.20230624"

# Uncommend and adjust JAVA_HOME if system path does not point to JDK 17
# JAVA_HOME="/usr/local/opt/openjdk@17"
# PATH="$JAVA_HOME/bin:$PATH"

# Sanity checks...
if [ ! -f "jar/NearInfinity.jar" ]
then
    echo "File does not exist: ./jar/NearInfinity.jar"    
    echo "Please ensure that the subfolder `jar` exists and contains the file `NearInfinity.jar`."
    exit 1
fi

# Generating file version for PKG archive
if [ -z ${NI_VERSION+x} ]
then
    NI_VERSION=$(java -jar "jar/NearInfinity.jar" -version 2>/dev/null | sed -E 's/^[^0-9]+//' | sed -E 's/-/./g')
fi

# Detecting system architecture
NI_ARCH="$(uname -m)"

# Building PKG archive
which jpackage >/dev/null 2>&1 && (
    echo "Building Near Infinity PKG archive (version ${NI_VERSION})..."
    jpackage \
    --type pkg \
    --name NearInfinity \
    --input ./jar \
    --main-class org.infinity.NearInfinity \
    --main-jar NearInfinity.jar \
    --app-version $NI_VERSION \
    --description "Near Infinity" \
    --mac-package-name "Near Infinity" \
    --resource-dir package/macos || (
        echo "Failed to create PKG archive"
        exit 1
    )
    mv "NearInfinity-${NI_VERSION}.pkg" "NearInfinity-macos-${NI_ARCH}-${NI_VERSION}.pkg" || (
        echo "Failed to rename PKG archive (NearInfinity-${NI_VERSION}.pkg -> NearInfinity-macos-${NI_ARCH}-${NI_VERSION}.pkg)"
        exit 1
    )
) || (
    echo "Could not find 'jpackage' command."
    exit 1
)
