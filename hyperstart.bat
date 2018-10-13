@ECHO off

REM Change shell for hyper.
REM
REM Usage:
REM   1. set your shell to '' (use CMD)
REM   1. your shellArgs to ["/C", "path\\to\\your\\hyperstart.bat"]
REM
REM Ref: https://gist.github.com/ssugiyama/c28e10aa656e5a6aba210e7cd907cc3a

:top
CLS
ECHO Choose a shell:
ECHO [1] cmd
ECHO [2] PowerShell
ECHO [3] ubuntu
ECHO.
ECHO [4] restart elevated
ECHO [5] exit
ECHO.

CHOICE /N /C:12345 /M "> "
CLS
IF ERRORLEVEL ==5 GOTO end
IF ERRORLEVEL ==4 powershell -Command "Start-Process hyper -Verb RunAs"
IF ERRORLEVEL ==3 ubuntu
IF ERRORLEVEL ==2 powershell
IF ERRORLEVEL ==1 cmd

CLS
ECHO Switch or exit?
ECHO [1] Switch
ECHO [2] Exit

CHOICE /N /C:12 /D 2 /T 5 /M "> "
IF ERRORLEVEL ==2 GOTO end
IF ERRORLEVEL ==1 GOTO top

:end

exit 0
