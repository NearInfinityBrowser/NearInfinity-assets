@echo off
setlocal enableextensions

REM *** UNCOMMENT TO OVERRIDE AUTODETECTED NI VERSION ***
REM Version format scheme: major.minor.yyyy.mmdd
REM - where yyyy: year, mm: month, dd: day
REM - each version element must be in range [0, 65535]
REM set NI_VERSION=2.3.2023.0624

REM Uncomment and adjust JAVA_HOME path if needed
REM set JAVA_HOME=D:\Utils\jdk1.17.0
REM set PATH=%JAVA_HOME%\bin;%PATH%
REM set CLASSPATH=%JAVA_HOME%\lib

REM Sanity checks...
if not exist %JAVA_HOME%\bin\jpackage.exe (
  echo ERROR: Could not find `jpackage.exe` in JDK bin path: %JAVA_HOME%\bin
  goto failed
)

if not exist jar\NearInfinity.jar (
  echo ERROR: File does not exist: ./jar/NearInfinity.jar
  echo Please ensure that the subfolder `jar` exists and contains the file `NearInfinity.jar`.
  goto failed
)

REM Use overridden NI_VERSION value if defined
if defined NI_VERSION (
  goto build
)

REM Storing NearInfinity.jar version output to JAR_VERSION variable
REM Expected version string format: Near Infinity vX.Y-yyyymmdd
REM Deviations from the expected version format (e.g. additional release suffixes) requires NI_VERSION to be overridden
for /f "tokens=*" %%g in ('java -jar jar\NearInfinity.jar -version') do (set JAR_VERSION=%%g)

REM Extracting file version for portable
set NI_VERSION=%JAR_VERSION:~-12,-9%.%JAR_VERSION:~-8,-4%.%JAR_VERSION:~-4%

:build
REM Building portable archive
echo Building Near Infinity portable (version %NI_VERSION%)...
jpackage.exe ^
  --type app-image ^
  --input "./jar" ^
  --name "NearInfinity" ^
  --main-class "org.infinity.NearInfinity" ^
  --main-jar "NearInfinity.jar" ^
  --app-version "%NI_VERSION%" ^
  --description "Near Infinity" ^
  --icon "package/windows/NearInfinity.ico" || goto failed
REM zip.exe -qr "NearInfinity-portable-win-%NI_VERSION%.zip" NearInfinity || goto failed
powershell -Command "& {Compress-Archive -Path .\NearInfinity -DestinationPath NearInfinity-portable-win-%NI_VERSION%.zip}" || goto failed
echo Portable archive successfully created: NearInfinity-portable-win-%NI_VERSION%.zip
goto completed

:failed
exit /b 1

:completed
exit /b 0
