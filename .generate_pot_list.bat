@echo off
setlocal enabledelayedexpansion

REM Set base path
set "base=%cd%"

REM Initialize variable
set "reslist="

REM Loop through .gd and .tscn files
for /r %%f in (*.gd *.tscn) do (
    REM Get relative path
    set "filepath=%%f"
    set "relpath=!filepath:%base%\=!"
    
    REM Replace backslashes with forward slashes
    set "relpath=!relpath:\=/!"
    
    REM Wrap with "res://..." and add quotes
    set "entry=\"res://!relpath!\""
    
    REM Append to list
    if defined reslist (
        set "reslist=!reslist!,!entry!"
    ) else (
        set "reslist=!entry!"
    )
)

REM Write the list to a fixed output file
echo !reslist! > res_paths.txt

echo Done. Output saved to: res_paths.txt
endlocal
