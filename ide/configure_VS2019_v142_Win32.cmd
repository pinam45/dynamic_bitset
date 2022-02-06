@echo off
set TARGET="Visual Studio 16 2019"
set TOOLSET=v142
set ARCH=Win32
set CFGS=Debug;RelWithDebInfo;Release;Sanitize
set OUT=VS2019_%TOOLSET%_%ARCH%
mkdir %OUT% 2>NUL
cmd /C "pushd %OUT% & cmake ../.. -G %TARGET% -T %TOOLSET% -A %ARCH% -DCMAKE_CONFIGURATION_TYPES=%CFGS%"
