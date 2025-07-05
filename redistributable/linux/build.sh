#!/bin/sh

# *** UNCOMMENT TO OVERRIDE AUTODETECTED NI VERSION ***
# Version format scheme: major.minor.yyyymmdd[-r]
# - where yyyy: year, mm: month, dd: day, r: optional release suffix
# NI_VERSION="2.3.20230624"

# Sanity checks...
if [ ! -f "jar/NearInfinity.jar" ]
then
    echo "File does not exist: ./jar/NearInfinity.jar"    
    echo "Please ensure that the subfolder `jar` exists and contains the file `NearInfinity.jar`."
    exit 1
fi

# Generating file version for AppImage package
if [ -z ${NI_VERSION+x} ]
then
    NI_VERSION=$(java -jar "jar/NearInfinity.jar" -version 2>/dev/null | sed -E 's/^[^0-9]+//' | sed -E 's/-/./g')
fi

# Detecting system architecture
NI_ARCH="$(uname -m)"

# Name of the AppImage file
APPIMAGE_FILE="NearInfinity-${NI_ARCH}-${NI_VERSION}.AppImage"

# Base folder of the AppImage container
APPIMAGE_DIR="NearInfinity.AppDir"

# URL of the appimagetool
APPIMAGETOOL="appimagetool-${NI_ARCH}.AppImage"
APPIMAGETOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/${APPIMAGETOOL}"

# Installing appimagetool
wget "${APPIMAGETOOL_URL}" || ( echo "Could not download ${APPIMAGETOOL}."; return 1 )
chmod +x "${APPIMAGETOOL}" || ( echo "Could not make ${APPIMAGETOOL} executable."; return 1 )
if [ ! -x "${APPIMAGETOOL}" ]
then
  echo "Could not install ${APPIMAGETOOL}."
  exit 1
fi

# Setting up AppDir structure
mkdir -p "${APPIMAGE_DIR}/usr/bin"
mkdir -p "${APPIMAGE_DIR}/usr/lib"
mkdir -p "${APPIMAGE_DIR}/usr/share/applications"
mkdir -p "${APPIMAGE_DIR}/usr/share/metainfo"
mkdir -p "${APPIMAGE_DIR}/usr/share/icons/hicolor/256x256/apps"

cp -a "${JAVA_HOME}/." "${APPIMAGE_DIR}/usr/lib/jre/" || ( echo "Could not install Java Runtime package."; return 1 )

install -m644 "./jar/NearInfinity.jar" "${APPIMAGE_DIR}/usr/bin/" || ( echo "Could not install NearInfinity.jar"; return 1 )

install -m755 "./package/AppRun" "${APPIMAGE_DIR}/" || ( echo "Could not install AppRun script."; return 1 )

install -m644 "./package/org.infinity.nearinfinity.desktop" "${APPIMAGE_DIR}/usr/share/applications/" || ( echo "Could not install org.infinity.nearinfinity.desktop."; return 1 )
ln -s "usr/share/applications/org.infinity.nearinfinity.desktop" "${APPIMAGE_DIR}/org.infinity.nearinfinity.desktop" || ( echo "Could not create symlink org.infinity.nearinfinity.desktop."; return 1 )

install -m644 "./package/org.infinity.nearinfinity.png" "${APPIMAGE_DIR}/usr/share/icons/hicolor/256x256/apps/" || ( echo "Could not install org.infinity.nearinfinity.png."; return 1 )
ln -s "usr/share/icons/hicolor/256x256/apps/org.infinity.nearinfinity.png" "${APPIMAGE_DIR}/org.infinity.nearinfinity.png" || ( echo "Could not create symlink org.infinity.nearinfinity.png."; return 1 )
ln -s "org.infinity.nearinfinity.png" "${APPIMAGE_DIR}/.DirIcon" || ( echo "Could not create symlink .DirIcon."; return 1 )

install -m644 "./package/org.infinity.nearinfinity.appdata.xml" "${APPIMAGE_DIR}/usr/share/metainfo/" || ( echo "Could not install org.infinity.nearinfinity.appdata.xml."; return 1 )

# Building the AppImage
./$APPIMAGETOOL "${APPIMAGE_DIR}" "${APPIMAGE_FILE}" || ( echo "Failed to create AppImage file."; return 1 )
