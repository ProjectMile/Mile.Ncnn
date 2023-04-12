@setlocal

@echo off

set VisualStudioInstallerFolder="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
if %PROCESSOR_ARCHITECTURE%==x86 set VisualStudioInstallerFolder="%ProgramFiles%\Microsoft Visual Studio\Installer"

pushd %VisualStudioInstallerFolder%
for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set VisualStudioInstallDir=%%i
)
popd

call "%VisualStudioInstallDir%\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86

set ObjectFolder="%~dp0Output\Objects\x86"
set BinaryFolder="%~dp0Output\Binaries\x86"

rem Remove the output folder for a fresh compile.
rd /s /q %ObjectFolder%
rd /s /q %BinaryFolder%

mkdir %BinaryFolder%

mkdir %ObjectFolder%\ncnn
pushd %ObjectFolder%\ncnn
cmake -DCMAKE_INSTALL_PREFIX=%BinaryFolder% -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DNCNN_BUILD_WITH_STATIC_CRT=ON -DNCNN_RUNTIME_CPU=OFF -DNCNN_AVX2=OFF -DNCNN_AVX=OFF -DNCNN_AVX512=OFF -DNCNN_XOP=OFF ../../../../ncnn
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
cmake --build . --parallel
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
ninja install
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

@endlocal