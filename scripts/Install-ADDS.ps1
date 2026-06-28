<#
.SYNOPSIS
    Installs AD DS and promotes this server into the first DC of a new forest.
.LINK
    https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest
#>

param(
    [string]$DomainName = "lab.local",
    [string]$NetbiosName = "LAB",
    [securestring]$SafeModePassword
)

$ErrorActionPreference = "Stop"

# If no DSRM password was passed in, prompt for one securely (masked input).
# Avoids passing $null into Install-ADDSForest's -SafeModeAdministratorPassword.
if (-not $SafeModePassword) {
    $SafeModePassword = Read-Host -AsSecureString -Prompt "Enter a DSRM (recovery) password"
}

# [WindowsIdentity]::GetCurrent()  → who is this process running as? (.NET)
# New-Object cmdlet  → wrap that identity in a principal so we can ask about roles
# WindowsPrincipal.IsInRole + WindowsBuiltInRole enum  → "am I in the Administrators role?"
# if / -not  → branch on the negative case
# throw  → abort the script with a terminating error
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please run this script in an elevated (Administrator) PowerShell session."
}

# Tell the operator what's about to happen (cyan = status/progress message).
# Write-Host prints only to the console; it does NOT send anything down the pipeline.
Write-Host "Installing the AD DS role..." -ForegroundColor Cyan

# Install the AD DS role and capture the result so we can check it afterward.
# $result holds Success, RestartNeeded, and ExitCode info from the install.
$result = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# AD DS installs sometimes need a reboot before the server can be promoted.
# Check the flag and warn the operator if so (yellow = warning).
if ($result.RestartNeeded -eq 'Yes') {
    Write-Host "A restart is required before promotion. Reboot, then re-run this script." -ForegroundColor Yellow
    return   # stop here instead of promoting on a dirty state
}

# Install-ADDSForest creates a brand-new forest and makes this box its first Domain Controller
# DomainName = is the FQDN of the new forest root domain, e.g. corp.control.com
# DomainNetbiosName = the short NetBIOS name (≤15 chars, single label). If omitted, it's auto-derived from -DomainName
# SafeModeAdministratorPassword = The DSRM (Directory Services Restore Mode) password (recovery password used when booting the DC into safe mode)
# InstallDns = Installs/configures the DNS Server role for the forest.
# Force = Runs without prompting for confirmation.
Install-ADDSForest `
    -DomainName                    $DomainName `
    -DomainNetbiosName             $NetbiosName `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns `
    -Force
