# -------------------------------------------
# PSReadLine Setup
# -------------------------------------------

# Show navigable menu of all options when hitting Tab
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Enable Predictive Intellisense
Set-PSReadLineOption -PredictionSource History
# Use Ctrl-F to fill next suggested word
Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord
# Set Color to be a more clear grey
Set-PSReadLineOption -Colors @{ InlinePrediction = '#808080'}
# Show history as a list rather than in line (switch with F2)
Set-PSReadLineOption -PredictionViewStyle ListView
# Change history to fill in only those that start with what's typed
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# Because defaults overridden, get that behaviour with ctrl arrow
Set-PSReadLineKeyHandler -Key Ctrl+UpArrow -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+DownArrow -Function NextHistory

# Set colors
Set-PSReadLineOption -Colors @{
  Command = "`e[1;94m" # blue, bold
  Error   = "DarkRed"
  String  = "DarkGreen"
  Comment = "`e[90;3m" # darkgray, italic
  Parameter = "Yellow"
  Keyword = "Magenta"
}

# -------------------------------------------
# Module Imports
# -------------------------------------------

# Add extra easier ways to use cd
Import-Module cd-extras

# Add Icons in Terminal to Get-ChildItem
Import-Module -Name Terminal-Icons

# -------------------------------------------
# Zoxide
# -------------------------------------------

Invoke-Expression (& { (zoxide init powershell --hook pwd | Out-String) })

# -------------------------------------------
# Yazi
# -------------------------------------------

function yy
{
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
  {
    Set-Location -LiteralPath $cwd
  }
  Remove-Item -Path $tmp
}

# -------------------------------------------
# Util Functions
# -------------------------------------------

function Find-Windots
{
  <#
  .SYNOPSIS
    Finds the local Windots repository.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProfilePath
  )

  Write-Verbose "Resolving the symbolic link for the profile"
  $profileSymbolicLink = Get-ChildItem $ProfilePath | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts
  return Split-Path $profileSymbolicLink.Target
}

# -------------------------------------------
# Env Variables
# -------------------------------------------
$Env:WindotsRepo = Find-Windots -ProfilePath $PSScriptRoot
$Env:BAT_CONFIG_DIR = "$Env:WindotsRepo\bat"

$Env:FZF_DEFAULT_OPTS = @"
--height 40%
--layout reverse
--border rounded
--info inline-right
--highlight-line
--ansi
--color bg+:#2d3f76
--color border:#589ed7
--color fg:#c8d3f5
--color gutter:-1
--color header:#ff966c
--color hl+:#65bcff
--color hl:#65bcff
--color info:#545c7e
--color marker:#ff007c
--color pointer:#ff007c
--color prompt:#65bcff
--color query:#c8d3f5:regular
--color scrollbar:#589ed7
--color separator:#ff966c
--color spinner:#ff007c
--preview-window border-rounded:wrap
--bind 'ctrl-/:toggle-preview'
"@

$Env:FZF_DEFAULT_COMMAND = "fd --type f"
Set-PsFzfOption -EnableFd -EnableAliasFuzzyHistory -EnableAliasFuzzySetLocation

# -------------------------------------------
# Remote
# -------------------------------------------

$Env:NVIM_LISTEN_ADDRESS = "\\.\pipe\nvim-nvr"

# NOTE: Pure nvim way doesn't work properly, so ensure nvim-remote is installed by running
# pip install nvim-remote

function nvr
{
  &(Get-Command nvr -CommandType Application) -s --nostart -p $args;
  if ($LastExitCode -ne 0)
  {
    nve $args
  }
}
function nve
{
  nvim --listen "$env:NVIM_LISTEN_ADDRESS" $args
}

# -------------------------------------------
# Prompt Setup
# -------------------------------------------
oh-my-posh init pwsh --config "$HOME\omp_themes\kyzan.omp.json" | Invoke-Expression

