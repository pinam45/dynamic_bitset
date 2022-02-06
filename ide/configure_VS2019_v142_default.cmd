@echo off
set TARGET="Visual Studio 16 2019"
set TOOLSET=v142
set CFGS=Debug;RelWithDebInfo;Release;Sanitize
set OUT=VS2019_%TOOLSET%_default
mkdir %OUT% 2>NUL
cmd /C "pushd %OUT% & cmake ../.. -G %TARGET% -T %TOOLSET% -DCMAKE_CONFIGURATION_TYPES=%CFGS%"
