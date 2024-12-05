function Update-ColorMode
{
  $currentValue = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme").AppsUseLightTheme

  if ($currentValue -eq 0)
  {
    $ColorMode = "dark"
  } else
  {
    $ColorMode = "light"
  }

  # Needed for Oh My Posh?
  Set-ItemProperty -Path HKCU:\Environment -Name 'ColorMode' -Value $ColorMode

  $wslPath = "\\wsl.localhost\Ubuntu\home\kyzan\.config"

  # Define theme names
  $darkTheme = "tokyonight_moon"
  $lightTheme = "catppuccin-latte"

  # Clear environment variables if needed
  $Env:BAT_THEME = ""
  $Env:FZF_DEFAULT_OPTS = ""

  # Set Lazygit colors
  $lazygitConfigFile = "$Env:WindotsRepo\lazygit\config.yml"
  $lazygitDefaults = Get-Content "$Env:WindotsRepo\lazygit\default.txt"
  $lazygitTheme = Get-Content "$Env:WindotsRepo\lazygit\$ColorMode.txt"
  Set-Content -Path $lazygitConfigFile -Value $lazygitDefaults
  Add-Content -Path $lazygitConfigFile -Value $lazygitTheme
  $Env:LG_CONFIG_FILE="$Env:WindotsRepo\lazygit\config.yml"
  Set-ItemProperty -Path HKCU:\Environment -Name 'LG_CONFIG_FILE' -Value "$Env:WindotsRepo\lazygit\config.yml"

  # Set fzf options
  $fzfDefaults = Get-Content "$Env:WindotsRepo\fzf\default"
  $fzfTheme = Get-Content "$Env:WindotsRepo\fzf\$ColorMode"
  Set-Content -Path $Env:FZF_DEFAULT_OPTS_FILE -Value $fzfDefaults
  Add-Content -Path $Env:FZF_DEFAULT_OPTS_FILE -Value $fzfTheme

  if ($currentValue -ne 0)
  {
    $sedPattern = 's/' + $darkTheme + '/' + $lightTheme + '/'
    $wezSedPattern = 's/M.scheme = "' + $darkTheme + '"/' + 'M.scheme = "' + $lightTheme + '"/'
    $ompSedPattern = 's/"ColorMode": "dark"/"ColorMode": "light"/'
    #$starshipPattern = 's/palette = "' + $darkTheme + '"/' + 'palette = "' + $lightTheme + '"/'
    #$starshipPattern 's/palette = "$darkTheme"/palette = "$lightTheme"/'
    $nvimSedPattern = 's/M.colormode = "dark"/M.colormode = "light"/'
    $termPattern = 's/"colorScheme": "Tokyonight Custom"/"colorScheme": "Catppuccin Latte"/'
  } else
  {
    $sedPattern = 's/' + $lightTheme + '/' + $darkTheme + '/'
    $wezSedPattern = 's/M.scheme = "' + $lightTheme + '"/' + 'M.scheme = "' + $darkTheme + '"/'
    $ompSedPattern = 's/"ColorMode": "light"/"ColorMode": "dark"/'
    #$starshipPattern = 's/palette = "' + $lightTheme + '"/' + 'palette = "' + $darkTheme + '"/'
    $nvimSedPattern = 's/M.colormode = "light"/M.colormode = "dark"/'
    $termPattern = 's/"colorScheme": "Catppuccin Latte"/"colorScheme": "Tokyonight Custom"/'
  }

  # Update yazi flavor using sed
  sed -i $sedPattern $Env:WindotsRepo\yazi\config\theme.toml
  #sed -i $sedPattern --follow-symlinks $wslPath\yazi\theme.toml

  # Update Wezterm colorscheme using sed rather than uservars
  sed -i $wezSedPattern $Env:WindotsRepo\wezterm\colorscheme.lua

  # Update Oh My Posh palette using sed to update var
  sed -i $ompSedPattern $Env:WindotsRepo\omp_themes\kyzan.omp.json

  ## Update Starship
  #sed -i $starshipPattern --follow-symlinks $wslPath\starship.toml

  # Update Bat to use correct theme using sed
  sed -i $sedPattern $Env:WindotsRepo\bat\config
  #sed -i $sedPattern --follow-symlinks $wslPath\bat\config

  # Update nvim colortheme
  sed -i $nvimSedPattern $Env:WindotsRepo\nvim\lua\config\colormode.lua
  #sed -i $nvimSedPattern --follow-symlinks $wslPath\nvim\lua\config\colormode.lua

  # Update Windows Terminal colorscheme
  sed -i $termPattern $Env:WindotsRepo\windowsterminal\settings.json

  # Update WSL config
  wsl -e fish -c "update_color"
}

function Switch-ColorMode
{
  $current = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme").AppsUseLightTheme
  if ($current -eq 0)
  {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
  } else
  {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
  }
}
Set-Alias -Name setc -Value Switch-ColorMode
