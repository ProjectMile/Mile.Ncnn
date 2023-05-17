@setlocal

@echo off

set VisualStudioInstallerFolder="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
if %PROCESSOR_ARCHITECTURE%==x86 set VisualStudioInstallerFolder="%ProgramFiles%\Microsoft Visual Studio\Installer"

pushd %VisualStudioInstallerFolder%
for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set VisualStudioInstallDir=%%i
)
popd

call "%VisualStudioInstallDir%\VC\Auxiliary\Build\vcvarsall.bat" amd64

set ObjectFolder="%~dp0Output\Objects\x64"
set BinaryFolder="%~dp0Output\Binaries\x64"

rem Remove the output folder for a fresh compile.
rd /s /q %ObjectFolder%
rd /s /q %BinaryFolder%

mkdir %BinaryFolder%

set CommonOptions=-DCMAKE_INSTALL_PREFIX=%BinaryFolder% -G "Ninja" -DNCNN_VERSION_STRING="20230517" -DNCNN_BUILD_WITH_STATIC_CRT=ON -DNCNN_RUNTIME_CPU=OFF

mkdir %ObjectFolder%\ncnn_debug
pushd %ObjectFolder%\ncnn_debug
cmake %CommonOptions% -DCMAKE_BUILD_TYPE=Debug -DNCNN_AVX2=OFF -DNCNN_AVX=OFF -DNCNN_AVX512=OFF -DNCNN_XOP=OFF ../../../../ncnn
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
cmake --build . --parallel
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
ninja install
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

mkdir %ObjectFolder%\ncnn
pushd %ObjectFolder%\ncnn
cmake %CommonOptions% -DCMAKE_BUILD_TYPE=Release -DNCNN_AVX2=OFF -DNCNN_AVX=OFF -DNCNN_AVX512=OFF -DNCNN_XOP=OFF ../../../../ncnn
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
cmake --build . --parallel
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
ninja install
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

@endlocal