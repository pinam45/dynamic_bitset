@echo off
set TARGET="Visual Studio 17 2022"
set TOOLSET=v143
set CFGS=Debug;RelWithDebInfo;Release;Sanitize
set OUT=VS2022_%TOOLSET%_default
mkdir %OUT% 2>NUL
cmd /C "pushd %OUT% & cmake ../.. -G %TARGET% -T %TOOLSET% -DCMAKE_CONFIGURATION_TYPES=%CFGS%"
