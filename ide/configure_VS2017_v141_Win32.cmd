@echo off
set TARGET="Visual Studio 15 2017"
set TOOLSET=v141
set ARCH=Win32
set CFGS=Debug;RelWithDebInfo;Release
set OUT=VS2017_%TOOLSET%_%ARCH%
mkdir %OUT% 2>NUL
cmd /C "pushd %OUT% & cmake ../.. -G %TARGET% -T %TOOLSET% -A %ARCH% -DCMAKE_CONFIGURATION_TYPES=%CFGS%"
