param()

$global:ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

$msbuild = $null
if (!(Test-Path vswhere.exe)) {
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/Microsoft/vswhere/releases/download/2.1.3/vswhere.exe", "vswhere.exe")
}
$path = .\vswhere.exe -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
if ($path) {
    $path = join-path $path 'MSBuild\15.0\Bin\MSBuild.exe'
    if (test-path $path) {
        $msbuild = $path
    }
}
if ($msbuild -eq $null) {
    Write-Error "Unable to find MSBuild!"
}

Write-Output "Building 32-bit library (Windows)..."
if (Test-Path build32) {
    Remove-Item -Force -Recurse build32
}
mkdir build32
Push-Location build32
try {
    cmake -G "Visual Studio 15 2017" ..
    if ($LastExitCode -ne 0) { throw "cmake failed" }
    & $msbuild /m /p:Configuration=Release .\HiveMP.ClientConnect.sln
    if ($LastExitCode -ne 0) { throw "Building solution failed" }
}
finally
{
    Pop-Location
}

Write-Output "Building 64-bit library (Windows)..."
if (Test-Path build64) {
    Remove-Item -Force -Recurse build64
}
mkdir build64
try {
    cmake -G "Visual Studio 15 2017 Win64" ..
    if ($LastExitCode -ne 0) { throw "cmake failed" }
    & $msbuild /m /p:Configuration=Release .\HiveMP.ClientConnect.sln
    if ($LastExitCode -ne 0) { throw "Building solution failed" }
}
finally
{
    Pop-Location
}