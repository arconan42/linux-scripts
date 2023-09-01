@echo off
setlocal

:: Specify the folder name and file name
set "folderName=NewFolder"
set "fileName=NewFile.txt"

:: Create the folder in C:\temp
mkdir "C:\temp\%folderName%"

:: Create the text file inside the new folder
echo This is a new text file. > "C:\temp\%folderName%\%fileName%"

:: Display a message indicating the operation is complete
echo Text file "%fileName%" created in "C:\temp\%folderName%"

endlocal
