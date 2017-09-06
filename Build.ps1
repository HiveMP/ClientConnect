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

Write-Output "Hotpatching curl CMakeLists..."
$content = Get-Content -Raw -Path curl\CMakeLists.txt
if (!$content.Contains("#add_subdirectory(docs)"))
{
    $content = $content.Replace("add_subdirectory(docs)", "#add_subdirectory(docs)");
    Set-Content -Path curl\CMakeLists.txt -Value $content
}

Write-Output "Building 32-bit library (Windows)..."
if (!(Test-Path build32)) {
    mkdir build32
}
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
if (!(Test-Path build64)) {
    mkdir build64
}
Push-Location build64
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

Write-Output "Running test (32-bit version)"
Push-Location .\build32\Release
try {
    .\HiveMP.SteamTest.exe | Tee-Object -Variable "Result"
    Write-Output "--------------------------------"
    Write-Output $Result
    Write-Output "--------------------------------"
    if ([regex]::Matches($Result, "TEST PASS").Count -ne 2)
    {
        Write-Error "32-bit test failed!"
    }
    else
    {
        Write-Output "32-bit test passed!"
    }
}
finally
{
    Pop-Location
}

Write-Output "Running test (64-bit version)"
Push-Location .\build64\Release
try {
    .\HiveMP.SteamTest.exe | Tee-Object -Variable "Result"
    Write-Output "--------------------------------"
    Write-Output $Result
    Write-Output "--------------------------------"
    if ([regex]::Matches($Result, "TEST PASS").Count -ne 2)
    {
        Write-Error "64-bit test failed!"
    }
    else
    {
        Write-Output "64-bit test passed!"
    }
}
finally
{
    Pop-Location
}

Write-Output "Creating distribution structure..."
if (Test-Path .\dist) {
    Remove-Item -Force -Recurse .\dist
}
mkdir .\dist
mkdir .\dist\sdk
mkdir .\dist\sdk\Win32
mkdir .\dist\sdk\Win64
mkdir .\dist\core
mkdir .\dist\core\cURL
mkdir .\dist\core\cURL\impl
Copy-Item .\build32\Release\HiveMP.ClientConnect.dll .\dist\sdk\Win32\
Copy-Item .\build32\Release\libcurl.dll .\dist\sdk\Win32\
Copy-Item .\build64\Release\HiveMP.ClientConnect.dll .\dist\sdk\Win64\
Copy-Item .\build64\Release\libcurl.dll .\dist\sdk\Win64\
Copy-Item .\HiveMP.ClientConnect\connect.h .\dist\sdk\
Copy-Item .\README.md .\dist\sdk\
Copy-Item HiveMP.SteamTest\json.lua .\dist\core\
Copy-Item HiveMP.ClientConnect\lua-curl\lua\cURL.lua .\dist\core\cURL.lua
Copy-Item HiveMP.ClientConnect\lua-curl\lua\cURL\safe.lua .\dist\core\cURL\safe.lua
Copy-Item HiveMP.ClientConnect\lua-curl\lua\cURL\utils.lua .\dist\core\cURL\utils.lua
Copy-Item HiveMP.ClientConnect\lua-curl\lua\cURL\impl\cURL.lua .\dist\core\cURL\impl\cURL.lua

Write-Output "All done!"
exit 0