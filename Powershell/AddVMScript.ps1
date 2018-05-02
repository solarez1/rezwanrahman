Param(
$Vmname = "Rez-Machine2",
$Memory = "2500000000",
$NewVHD = "C:\Powershell_scripts\RezMachine\Virtual`Machines\Rez1.vhdx",
$VHDSize = "43000000000",
$NetSwitch = "Internal",
$W8ISO = "C:\Software\Server 2008R2\WS08R2_ENU_x64_STD.iso"
)

#$A = Read-Host "What is your name?"
#Write-Output $A

New-VM -Name $Vmname -MemoryStartupBytes $Memory -NewVHDPath $NewVHD -NewVHDSizeBytes $VHDSize 
Add-VMNetworkAdaptor -VMName $Vmname -SwitchName $NetSwitch

Set-VMDvdDrive -VMName $Vmname -Path $W8ISO
Start-VM $Vmname