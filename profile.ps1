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
# Module Imports
# -------------------------------------------

# Add extra easier ways to use cd
Import-Module cd-extras

# Add Icons in Terminal to Get-ChildItem
Import-Module -Name Terminal-Icons

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
oh-my-posh init pwsh --config "$HOME\omp_themes\kyzan.omp.json" | Invoke-Expression

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
  if ($useBack)
  {
    sed -i 's/M.useBack = false/M.useBack = true/' $Env:WindotsRepo\wezterm\colorscheme.lua
    Set-ItemProperty -Path HKCU:\Environment -Name 'WezBack' -Value "true"
  } else
  {
    sed -i 's/M.useBack = true/M.useBack = false/' $Env:WindotsRepo\wezterm\colorscheme.lua
    Set-ItemProperty -Path HKCU:\Environment -Name 'WezBack' -Value "false"
  }
}

function Switch-UseBack
{
  $back = Get-ItemPropertyValue -Path HKCU:\Environment -Name 'WezBack'
  if ($back -eq "true")
  {
    $useBack = $false
  } else
  {
    $useBack = $true
  }
  Set-UseBack $useBack
}

Set-Alias -Name ub -Value Switch-UseBack
Set-Alias -Name SetUseBack -Value Set-UseBack

# -------------------------------------------
# Color scheme changing
# -------------------------------------------

function Set-ColorMode
{
  <#
  .SYNOPSIS
    Set whether the terminal should be dark mode or light mode
  #>
  param(
    [string]$ColorMode
  )
  if ($ColorMode -ne "light" -and $ColorMode -ne "dark")
  {
    return
  }

  # Define theme names
  $darkTheme = "tokyonight_moon"
  $lightTheme = "catppuccin-latte"

  # Clear environment variables if needed
  $Env:BAT_THEME = ""
  $Env:FZF_DEFAULT_OPTS = ""

  Set-ItemProperty -Path HKCU:\Environment -Name 'NvimColorMode' -Value $ColorMode

  # Set Lazygit colors
  $lazygitConfigFile = "$Env:WindotsRepo\lazygit\config.yml"
  $lazygitDefaults = Get-Content "$Env:WindotsRepo\lazygit\default.txt"
  $lazygitTheme = Get-Content "$Env:WindotsRepo\lazygit\$ColorMode.txt"
  Set-Content -Path $lazygitConfigFile -Value $lazygitDefaults
  Add-Content -Path $lazygitConfigFile -Value $lazygitTheme

  # Set fzf options
  $fzfDefaults = Get-Content "$Env:WindotsRepo\fzf\default"
  $fzfTheme = Get-Content "$Env:WindotsRepo\fzf\$ColorMode"
  Set-Content -Path $Env:FZF_DEFAULT_OPTS_FILE -Value $fzfDefaults
  Add-Content -Path $Env:FZF_DEFAULT_OPTS_FILE -Value $fzfTheme

  if ($ColorMode -eq "light")
  {
    $sedPattern = 's/' + $darkTheme + '/' + $lightTheme + '/'
    $wezSedPattern = 's/M.scheme = "' + $darkTheme + '"/' + 'M.scheme = "' + $lightTheme + '"/'
    $ompSedPattern = 's/"ColorMode": "dark"/"ColorMode": "light"/'
    $nvimSedPattern = 's/M.colormode = "dark"/M.colormode = "light"/'
  } else
  {
    $sedPattern = 's/' + $lightTheme + '/' + $darkTheme + '/'
    $wezSedPattern = 's/M.scheme = "' + $lightTheme + '"/' + 'M.scheme = "' + $darkTheme + '"/'
    $ompSedPattern = 's/"ColorMode": "light"/"ColorMode": "dark"/'
    $nvimSedPattern = 's/M.colormode = "light"/M.colormode = "dark"/'
  }

  # Update yazi flavor using sed
  sed -i $sedPattern $Env:WindotsRepo\yazi\config\theme.toml

  # Update Wezterm colorscheme using sed rather than uservars
  sed -i $wezSedPattern $Env:WindotsRepo\wezterm\colorscheme.lua

  # Update Oh My Posh palette using sed to update var
  sed -i $ompSedPattern $Env:WindotsRepo\omp_themes\kyzan.omp.json

  # Update Bat to use correct theme using sed
  sed -i $sedPattern $Env:WindotsRepo\bat\config

  # Update nvim colortheme
  sed -i $nvimSedPattern $Env:WindotsRepo\nvim\lua\config\colormode.lua
}

Set-Alias -Name SetColorMode -Value Set-ColorMode

# Aliases for setting dark mode and light mode quickly
function setd
{
  Set-ColorMode dark
}

function setl
{
  Set-ColorMode light
}

function Initialize-ColorMode
{
  <#
  .SYNOPSIS
    Sets a default color mode of dark, if color mode is not set.
  #>
  $mode = Get-ItemPropertyValue -Path HKCU:\Environment -Name 'NvimColorMode'
  if ($null -eq $mode)
  {
    Set-ColorMode "dark";
  } else
  {
    Set-ColorMode $mode
  }
}

function Switch-ColorMode
{
  $mode = Get-ItemPropertyValue -Path HKCU:\Environment -Name 'NvimColorMode'
  if ($null -eq $mode)
  {
    Initialize-ColorMode
    return
  }
  if ($mode -eq "light")
  {
    Set-ColorMode dark
  } else
  {
    Set-ColorMode light
  }
}

Set-Alias -Name setc -Value Switch-ColorMode

# -------------------------------------------
# Aliases
# -------------------------------------------

# Common typo I make
function exitr
{
  exit
}

# -------------------------------------------
# Final Parts
# -------------------------------------------

# Set color mode if not set
Initialize-ColorMode

# Set zoxide. Must be at the end of the script to work properly.
Invoke-Expression (& { (zoxide init powershell --hook prompt | Out-String) })
