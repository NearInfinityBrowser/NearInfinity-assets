@echo off
REM !!! ImageMagick must be installed and in your PATH !!!
where magick.exe >nul 2>&1 && (
  echo Building NearInfinity.ico ...
  magick.exe app/app-16.png app/app-32.png app/app-64.png app/app-128.png app/app-256.png NearInfinity.ico
  echo Done.
  exit /b 0
) || (
  echo ERROR: Could not find `ImageMagick` executable in your PATH.
  exit /b 1
)
