#Requires -RunAsAdministrator
#Requires -Version 7

# Linked Files (Destination => Source)
$symlinks = @{
  $PROFILE.CurrentUserAllHosts = ".\profile.ps1"
  "$HOME\AppData\Local\nvim" = ".\nvim"
  "$HOME\AppData\Local\lazygit" = ".\lazygit"
  "$HOME\.config\wezterm" = ".\wezterm"
  "$HOME\.glaze-wm" = ".\glaze-wm"
  "$HOME\AppData\Roaming\yazi" = ".\yazi"
  "$HOME\omp_themes" = ".\omp_themes"
}

$scoopDeps = @(
  "7zip"
  "bat"
  "eza"
  "fd"
  "fzf"
  "jq"
  "extras/lazygit"
  "less"
  "poppler"
  "ripgrep"
  "sed"
  "terminal-icons"
  "unar"
  "vcredist2022"
  "wezterm"
  "yazi"
  "zoxide"
)

$psModules = @(
  "cd-extras"
)

Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

# Install scoop if missing
if (-Not (Get-Command scoop -ErrorAction Ignore))
{
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  scoop bucket add extras
}

# Install missing scoop dependencies and Powershell modules
foreach ($scoopDep in $scoopDeps)
{
  scoop install $scoopDep
}

foreach ($psModule in $psModules)
{
  Install-Module $psModule
}

foreach ($symlink in $symlinks.GetEnumerator())
{
  # Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue
  Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
  New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}
