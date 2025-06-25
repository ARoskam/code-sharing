# This script creates a custom bootable ISO with the "press any key" option disabled
# Create the local file structure and edit the variables as needed:
$SourceIso   = "C:\ISOs\ISO\<<ISO_NAME>>.iso"
$CustomFiles = "C:\ISOs\CustomFiles"
$OutputIso   = "C:\ISOs\Output\<<NEW_ISO_NAME>>.iso"
$MountPath = "$env:TEMP\WinISOMount"
$WorkDir   = "$env:TEMP\WinISOWork"

# Clean up any previous runs
if (Test-Path $MountPath) { Dismount-DiskImage -ImagePath $SourceIso -ErrorAction SilentlyContinue; Remove-Item $MountPath -Recurse -Force }
if (Test-Path $WorkDir)   { Remove-Item $WorkDir -Recurse -Force }

# Mount the ISO
Mount-DiskImage -ImagePath $SourceIso
$Disk = Get-DiskImage -ImagePath $SourceIso | Get-Volume
$DriveLetter = $Disk.DriveLetter

# Copy ISO contents
New-Item -ItemType Directory -Path $WorkDir | Out-Null
robocopy "$DriveLetter`:\" $WorkDir /E

# Replace EFI Boot Files
$EfiBootPath = Join-Path $WorkDir "efi\microsoft\boot"

# Delete efisys.bin and cdboot.efi
Remove-Item -Path (Join-Path $EfiBootPath "efisys.bin") -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $EfiBootPath "cdboot.efi") -Force -ErrorAction SilentlyContinue

# Rename efisys_noprompt.bin to efisys.bin
if (Test-Path (Join-Path $EfiBootPath "efisys_noprompt.bin")) {
    Rename-Item -Path (Join-Path $EfiBootPath "efisys_noprompt.bin") -NewName "efisys.bin" -Force
}

# Rename cdboot_noprompt.efi to cdboot.efi
if (Test-Path (Join-Path $EfiBootPath "cdboot_noprompt.efi")) {
    Rename-Item -Path (Join-Path $EfiBootPath "cdboot_noprompt.efi") -NewName "cdboot.efi" -Force
}

# Dismount ISO
Dismount-DiskImage -ImagePath $SourceIso

# Copy custom files
Copy-Item -Path "$CustomFiles\*" -Destination $WorkDir -Recurse -Force

# Find oscdimg.exe
$Oscdimg = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
if (!(Test-Path $Oscdimg)) {
    Write-Error "oscdimg.exe not found. Please install Windows ADK and update the script path if needed."
    exit 1
}

# Ensure boot sector files exist
$BootSector = Join-Path $WorkDir "boot\etfsboot.com"
$EfiBootImage = Join-Path $WorkDir "efi\microsoft\boot\efisys.bin"
if (!(Test-Path $BootSector)) {
    Write-Error "Boot sector file etfsboot.com not found in $BootSector"
    exit 1
}
if (!(Test-Path $EfiBootImage)) {
    Write-Error "UEFI boot image efisys.bin not found in $EfiBootImage"
    exit 1
}

# Create new bootable ISO (BIOS + UEFI)
& $Oscdimg -bootdata:2#p0,e,b"$BootSector"#pEF,e,b"$EfiBootImage" -u2 -h -m -o $WorkDir $OutputIso

# Clean up
Remove-Item $WorkDir -Recurse -Force

Write-Host "Custom ISO created at $OutputIso"
