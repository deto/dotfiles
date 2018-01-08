PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"
%~dp0install_nvim.bat
%~dp0install_xwin.bat
PAUSE
