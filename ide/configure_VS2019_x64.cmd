@echo off
set TARGET="Visual Studio 16 2019"
set TOOLSET=v142
set ARCH="x64"
set CFGS=Debug;RelWithDebInfo;Release
set OUT=VS2019_%TOOLSET%_x64
mkdir %OUT% 2>NUL
cmd /C "pushd %OUT% & cmake ../.. -G %TARGET% -T %TOOLSET% -A %ARCH% -DCMAKE_CONFIGURATION_TYPES=%CFGS%"
