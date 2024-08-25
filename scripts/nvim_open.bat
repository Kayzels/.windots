@echo off

REM Can't figure out a nice way to set the path to the ps1 script
REM Can't access the Env variable for the Windots repo,
REM so setting it directly here.

pwsh -command "& C:\Users\Kyzan\.windots\scripts\open_with_nvim.ps1" %1

