REM ======================================
REM = Check out files                     
REM ======================================
set HOME=d:\Home\shawnliang
set VERSION=1.0.%BUILD_NUMBER%
cd "%WORKSPACE%\Wammer-Chrome"
"c:\Program Files (x86)\Git\bin\git.exe" clean -d -f
"c:\Program Files (x86)\Git\bin\git.exe" reset --hard
"c:\Program Files (x86)\Git\bin\git.exe" pull --progress

REM ==========================
REM === Write version info ===
REM ==========================
python -u buildVersion.py %VERSION%

REM ===========================
REM ===== Compress to ZIP =====
REM ===========================
"C:\Program Files\7-Zip\7z.exe" a -tzip "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension.zip" "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension"

REM ===========================
REM == Build Product Version ==
REM ===========================
"C:\Users\ShawnLiang\AppData\Local\Google\Chrome\Application\chrome.exe" --no-message-box --pack-extension="%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension" --pack-extension-key="%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension.pem"

ren "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension.crx" "production-WavefaceChromeExtension-%VERSION%.crx"
IF NOT %ERRORLEVEL% == 0 (exit /b %ERRORLEVEL%)

REM ===========================
REM == Build Develop Version ==
REM ===========================
del /Q "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension\manifest.json"
IF NOT %ERRORLEVEL% == 0 (exit /b %ERRORLEVEL%)

copy "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension\manifest_dev.json" "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension\manifest.json"
IF NOT %ERRORLEVEL% == 0 (exit /b %ERRORLEVEL%)

del /Q "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension\background.html"
IF NOT %ERRORLEVEL% == 0 (exit /b %ERRORLEVEL%)

copy "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension\background_dev.html" "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension\background.html"
IF NOT %ERRORLEVEL% == 0 (exit /b %ERRORLEVEL%)

"C:\Users\ShawnLiang\AppData\Local\Google\Chrome\Application\chrome.exe" --no-message-box --pack-extension="%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension" --pack-extension-key="%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension.pem"

ren "%WORKSPACE%\Wammer-Chrome\WavefaceChromeExtension.crx" "development-WavefaceChromeExtension-%VERSION%.crx"
IF NOT %ERRORLEVEL% == 0 (exit /b %ERRORLEVEL%)

REM ================================
REM == Publish to Develop Website ==
REM ================================
"C:\Program Files (x86)\WinSCP\WinSCP.exe" /console /command "open wammer@develop.waveface.com" "put development-WavefaceChromeExtension-%VERSION%.crx ./static/extensions/chrome/WavefaceChromeExtension.crx" "close" "exit"
"C:\Program Files (x86)\WinSCP\WinSCP.exe" /console /command "open wammer@develop.waveface.com" "put updates_dev.xml ./static/extensions/chrome/updates_dev.xml" "close" "exit"

REM ============================
REM ===== Backup to WF-NAS =====
REM ============================
python -u publishBin.py %VERSION%