@echo off
REM !!! ImageMagick must be installed and in your PATH !!!
where magick.exe >nul 2>&1 && (
  echo Building KeyIcon.ico ...
  magick.exe mime/mime-16.png mime/mime-32.png mime/mime-64.png mime/mime-128.png mime/mime-256.png KeyIcon.ico
  echo Done.
  exit /b 0
) || (
  echo ERROR: Could not find `ImageMagick` executable in your PATH.
  exit /b 1
)
