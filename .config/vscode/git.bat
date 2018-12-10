@echo off
wsl wslpath -aw $(git %*) 2> nul 
if not %errorlevel% == 0 (
    wsl git %*
)
@echo on