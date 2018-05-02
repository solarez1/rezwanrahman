#specify perameters to create VM
$Vmname = Read-Host "Enter the Virtual Machine Name"
$Memory = Read-Host "Enter Memory for server [Default]"
if($Memory -eq ""){$Memory=1024MB}
$NewVHD = Read-Host "Enter the location of the vhdx file [Default]"
if($NewVHD -eq ""){$NewVHD="C:\VM\RezMachine\Virtual Machines\Rez1.vhdx"}
$NetSwitch = Read-Host "Enter network name[Default]"
if($NetSwitch -eq ""){$NetSwitch="Internal"}
$ISO = Read-Host "Enter location of ISO [Default]"
if($ISO -eq ""){$ISO="\\EKTUKREZWAN\Software\Server2008R2\WS08R2_ENU_x64_STD.iso"}
$VHDSize = Read-Host "Enter the size of the vhdx [Default]"
if($VHDSize -eq ""){$VHDSize=40GB}

#create network switch
#New-VMSwitch $NetSwitch -NetAdapterName Ethernet

#create virtual machine
New-VM -Name $Vmname -MemoryStartupBytes $Memory -NewVHDPath $NewVHD -NewVHDSizeBytes $VHDSize #-WhatIf
Add-VMNetworkAdapter -VMName $Vmname -SwitchName $NetSwitch #-WhatIf

#New-PSDrive -Name $ISO -PSProvider Filesystem -Root \\EKTUKREZWAN\Software -Credential EKtron1\RRahman #-WhatIf
Set-VMDvdDrive -VMName $Vmname -Path $ISO #-WhatIf
Start-VM $Vmname
