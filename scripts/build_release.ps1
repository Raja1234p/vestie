# Vestie production release builds (Windows / PowerShell).
# Run from repo root: .\scripts\build_release.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "==> flutter pub get"
flutter pub get

Write-Host "==> flutter analyze"
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> flutter test"
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> Play Store App Bundle"
flutter build appbundle --release

Write-Host "==> Per-ABI APKs (smaller direct installs)"
flutter build apk --release --split-per-abi

Write-Host "Done. Outputs under build/app/outputs/"
