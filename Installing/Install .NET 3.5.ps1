 ################################################################
# Created By: Bastiaan van Haastrecht
# E-mail    : b.vanhaastrecht(-a-)gmail.com
# Date      : 23-11-2017
# Purpose   : Deploy .NET 3.5
#
#################################################################
# Disclaimer: Use this script at your own risk. The author is not
#             responsible for any loss arising out of the use of
#             this script.
#################################################################


$netThere = $false
$netVersions = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select Version

foreach ($netVersion in $netVersions) {
    if ($netVersion.Version -match "3.5") {
        $netThere = $true
    }
}

if ($netThere) {
	Write-Host ".NET 3.5 is installed"
} else {
	Write-Host ".NET is not installed, going to install"
	
	$dvdDrives = Get-WmiObject win32_logicaldisk -Filter "DriveType='5'"
	foreach ($dvddrive in $dvdDrives) {
		$drive = $dvddrive.DeviceID
		If (Test-Path "$drive\sources\sxs" -ErrorAction SilentlyContinue) {
			$sxsDrive = $drive
		}
	}

	if ([string]::IsNullOrEmpty($sxsDrive)) {
		Write-Error "ERROR: No Windows DVD drive found"
		Exit 1
	} else {
		Try {
			Install-WindowsFeature Net-Framework-Core -source "$drive\sources\sxs\"
		} Catch {
			Write-Error "ERROR : .NET 3.5 could not be installed"
			Exit 1
		}
		Write-Host ".NET 3.5 successfully installed"
	}
}