net stop bits
net stop wuauserv
net stop appidsvc
net stop cryptsvc
Del "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\*.*"
rmdir %systemroot%\SoftwareDistribution /S /Q
rmdir %systemroot%\system32\catroot2 /S /Q
net start bits
net start wuauserv
net start appidsvc
net start cryptsvc