@echo off
echo ==============================================
echo   VPN One - Build Android Release APK
echo ==============================================

if "%ANDROID_HOME%"=="" (
    echo [WARNING] ANDROID_HOME environment variable is not set.
    echo Please install Android Studio or the Android SDK command-line tools.
)

echo Running flutter pub get...
call E:\flutter\bin\flutter.bat pub get

echo Building APK (Release)...
call E:\flutter\bin\flutter.bat build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo.
    echo [FAILED] Build exited with code %ERRORLEVEL%.
)
pause

