
# Get the current value of the registry key
$currentValue = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme").AppsUseLightTheme

. $Env:WindotsRepo\scripts\color.ps1

# Monitor the registry key for changes
while ($true)
{
  $newValue = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme").AppsUseLightTheme
  if ($newValue -ne $currentValue)
  {
    # Trigger an action when the value changes
    #Write-Host "Registry value changed!"
    Update-ColorMode
    $currentValue = $newValue
  }
  Start-Sleep -Seconds 5
}
