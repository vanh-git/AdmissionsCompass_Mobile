$ErrorActionPreference = 'Stop'

$flutter = Join-Path $PSScriptRoot '.tools\flutter\bin\flutter.bat'
if (-not (Test-Path $flutter)) {
    throw 'Flutter SDK not found at .tools\flutter. Follow README.md to install it.'
}

& $flutter pub get
& $flutter run -d chrome
