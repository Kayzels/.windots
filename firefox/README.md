# Setting Up Firefox Profile

This hasn't been put in the `setup.ps1` file,
because the symlink would be different (and is randomised) per device.

You need to create the symlink yourself, from the Firefox profile folder
to the Windots one.

You can get the Firefox profile folder by opening Firefox,
selecting the hamburger menu > Help > More troubleshooting information > Profile Folder.

You need to delete (or backup elsewhere) the existing chrome folder inside there.
And then symlink chrome to the firefox folder.

Using Powershell, and doing the same as `setup.ps1`:

```ps1
$symlinks = @{
  "$HOME\AppData\Roaming\Mozilla\Firefox\Profiles\xxxxxxxx.default-release\chrome" = ".\firefox"
}
foreach ($symlink in $symlinks.GetEnumerator())
{
  Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
  New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}
```

---
