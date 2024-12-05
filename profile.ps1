# -------------------------------------------
# PSReadLine Setup
# -------------------------------------------

function Update-PSReadLine
{
  # Enable Predictive Intellisense
  Set-PSReadLineOption -PredictionSource History

  # Show history as a list rather than in line (switch with F2)
  Set-PSReadLineOption -PredictionViewStyle ListView

  # Show navigable menu of all options when hitting Tab
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

  # Set colors
  Set-PSReadLineOption -Colors @{
    InlinePrediction = '#808080' # clearer grey
    Command = "`e[1;94m" # blue, bold
    Error   = "DarkRed"
    String  = "DarkGreen"
    Comment = "`e[90;3m" # darkgray, italic
    Parameter = "Yellow"
    Keyword = "Magenta"
  }

  # Use Ctrl-F to fill next suggested word
  Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord

  # Change history to fill in only those that start with what's typed
  Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
  Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function HistorySearchForward

  # Because defaults overridden, get that behaviour with ctrl arrow
  Set-PSReadLineKeyHandler -Key Ctrl+UpArrow -Function PreviousHistory
  Set-PSReadLineKeyHandler -Key Ctrl+DownArrow -Function NextHistory
}

# NOTE: Set-PSReadLineOption messes up output in Neovim for ! commands
# So, only set these options when in an Interactive mode,
# which won't happen with Neovim
if (-not [Environment]::GetCommandLineArgs().Contains('-NonInteractive'))
{
  Update-PSReadLine
}

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

$WindotsRepo = Find-Windots -ProfilePath $PSScriptRoot
Set-ItemProperty -Path HKCU:\Environment -Name 'WindotsRepo' -Value $WindotsRepo
$Env:WindotsRepo = $WindotsRepo
$Env:BAT_CONFIG_DIR = "$Env:WindotsRepo\bat"
$Env:FZF_DEFAULT_OPTS_FILE = "$Env:WindotsRepo\fzf\config"

$Env:FZF_DEFAULT_COMMAND = "fd --type f"
Set-PsFzfOption -EnableFd -EnableAliasFuzzyHistory -EnableAliasFuzzySetLocation

# -------------------------------------------
# Remote
# -------------------------------------------

# Don't use environment variable for Nvim Remote: causes new instances of Nvim to crash
$listenAddress = "\\.\pipe\nvim-nvr"

function nvr
{
  if (Test-Path -Path $listenAddress)
  {
    nvim --server $listenAddress --remote-tab $args
  } else
  {
    nvim --listen $listenAddress $args
  }
}

# Do functionality in one function rather than split.
# I never remember which is nve and which is nvr,
# so just make nve an alias of nvr
function nve
{
  nvr $args
}

# -------------------------------------------
# Prompt Setup
# -------------------------------------------

$Env:POSH_THEME = "$HOME\omp_themes\kyzan.omp.json"
$Env:VIRTUAL_ENV_DISABLE_PROMPT=1

oh-my-posh --init --shell pwsh | Invoke-Expression

# -------------------------------------------
# Wezterm Background Changing
# -------------------------------------------

function Set-UseBack
{
  <#
  .SYNOPSIS
    Set whether to use background images in Wezterm or not.
  #>
  param(
    [Parameter(Mandatory=$true)]
    [bool]$useBack
  )
  $useBackString = $useBack.ToString()
  if ($useBack)
  {
    $wezSedPattern = 's/local use_back = false/local use_back = true/'
    $nvimSedPattern = 's/M.useBack = false/M.useBack = true/'
  } else
  {
    $wezSedPattern = 's/local use_back = true/local use_back = false/'
    $nvimSedPattern = 's/M.useBack = true/M.useBack = false/'
  }
  sed -i $wezSedPattern $Env:WindotsRepo\wezterm\wezterm.lua
  sed -i $nvimSedPattern $Env:WindotsRepo\nvim\lua\config\colormode.lua
  Set-ItemProperty -Path HKCU:\Environment -Name 'WezBack' -Value $useBackString
}

function Switch-UseBack
{
  $back = Get-ItemPropertyValue -Path HKCU:\Environment -Name 'WezBack'
  if ($back -eq $true.ToString())
  {
    $useBack = $false
  } else
  {
    $useBack = $true
  }
  Set-UseBack $useBack
}

function Get-UseBack
{
  $back = Get-ItemPropertyValue -Path HKCU:\Environment -Name 'WezBack'
  return $back
}

Set-Alias -Name ub -Value Switch-UseBack
Set-Alias -Name SetUseBack -Value Set-UseBack

# -------------------------------------------
# Color scheme changing
# -------------------------------------------

. $Env:WindotsRepo/scripts/color.ps1

# Set color mode if not set
#Update-ColorMode
#
#Start-Job -FilePath $Env:WindotsRepo/scripts/update_color.ps1 | Out-Null

# -------------------------------------------
# Aliases
# -------------------------------------------

# Common typo I make
function exitr
{
  exit
}
function q
{
  exit
}
function qa
{
  exit
}

# -------------------------------------------
# Final Parts
# -------------------------------------------

# Set zoxide. Must be at the end of the script to work properly.
Invoke-Expression (& { (zoxide init powershell --hook prompt | Out-String) })

function nvis
{
  param(
    [string]$nvimArgs
  )

  if ([string]::IsNullOrEmpty($nvimArgs))
  {
    C:\Users\Kyzan\scoop\shims\nvim.exe
  } else
  {
    C:\Users\Kyzan\scoop\shims\nvim.exe $nvimArgs
  }
}
