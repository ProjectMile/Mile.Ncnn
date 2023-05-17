@setlocal

@echo off

set PatchesFolder="%~dp0Patches"
set QtBaseFolder="%~dp0ncnn"

pushd %QtBaseFolder%
git am %PatchesFolder%\0001-Add-VC-LTL-support.patch
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

@endlocal