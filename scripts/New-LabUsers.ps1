<#
.SYNOPSIS
This script creates the users for the ActiveDirectory infastructure
 New-ADUser — https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser
  - New-ADOrganizationalUnit — https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit
  - Get-ADUser (idempotency check) — https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser
  - Get-ADOrganizationalUnit (idempotency check) — https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adorganizationalunit
#>

#(in depth explination from microsoft for explaining objects with Acctive Directory Domain Services.) 
# https://learn.microsoft.com/en-us/windows/win32/ad/object-names-and-identities
[String]$DomainDN = "DC=lab,DC=local"

# this variable holds text string for OUs
[String]$OUName = "LabUsers"

# This varaible Locataes the Source File
[String]$CsvPath

# Securestring encrypts plain text strings from RAM
# (https://learn.microsoft.com/en-us/dotnet/api/system.security.securestring?view=net-10.0)
[securestring]$DefaultPassword

# Anything inside of the param wrapper becomes a command line parameter, allows for pasing values dynamically
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.6
param(
  [Parameter(Mandatory = $true, HelpMessage = "Absolute path to your user CSV file.")]
  [ValidateScript({ Test-Path $_ -PathType Leaf })]
  [string]$CsvPath,

  [Parameter(Mandatory = $true, HelpMessage = "The sercure default password for new accounts.")]
  [System.Security.SecureString]$DefaultPassword,

  [string]$OUName = "LabUsers",
  [string]$DomainDN = "DC=lab,DC=local"
)

#Construct the full Active Directory path for the OU
$TargetOUDN = "OU=$OUName,$DomainDN"

#Check if the OU already exists
$ExistingOU = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$TargetOUDN'"

if ($null -eq $ExistingOU) {
  Write-Host "OU '$OUName' not found. Creating it now at: $TargetOUDN" -ForegroundColor Cyan

  # Create the OU if it is missing
  New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
} else {
    Write-Host "OU '$OUName' already exists. Skipping creation."
}

# Importing the CSV file and processing the 100 users...
$UserData = Import-Csv -Path $CsvPath

# Process each user row by row
foreach ($User in $UserData) {

  # Generate a unique SAM Account Name (logon name) from First and Last name columns
  # Example: "John" and "Doe" becomes "jdoe"
  $SamAccountName = ($User.FirstName.Substring(0,1) + $User.LastName).ToLower().Replace(" ","")

  # Check if the user already exists in Active Directory (Idempotency Check)
  $ExistingUser = Get-ADUser -

}

foreach ($UserData) {
  # First-initial + last name, lowercased, spaces stripped: "John", "Doe" -> "jdoe"
  $SamAccountName = ($User.FirstName.Substring(0,1) + $User.LastName).ToLower().Replace(" ","")
  if ($SamAccountName.Length -gt 20) { $SamAccountName = $SamAccountName.Substring(0,20) } # SAM hard limit

$Upn = "$SamAccountName@lab.local" # or derive from $DomainDN if you prefer

# Idempotency check: -Filter returns $nulll instead of throwing when not found.
$ExistingUser = get-aduser -Filter "$SamAccountName -eq '$SamAccountName'"

if ($null -ne $ExistingUser) {
  Write-Host "User '$SamAccountName' already exists, Skipping." -ForegroundColor DarkGray
  continue
}

}
