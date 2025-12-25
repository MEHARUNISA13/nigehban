@echo off
echo ========================================
echo Nigehbaan App - Clean Build Script
echo ========================================
echo.

echo [1/4] Cleaning Flutter project...
call flutter clean

echo.
echo [2/4] Getting dependencies...
call flutter pub get

echo.
echo [3/4] Building APK (this may take 5-10 minutes)...
call flutter build apk --debug

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-debug.apk
echo.
pause
