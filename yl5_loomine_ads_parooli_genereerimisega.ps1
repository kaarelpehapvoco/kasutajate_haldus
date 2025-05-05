<#
.SYNOPSIS
    Create a new AD user with a generated strong password.
.DESCRIPTION
    This script imports the ActiveDirectory module, collects user details via parameters, generates a complex password,
    checks for existing accounts, and creates a new AD user in the specified OU path.
.PARAMETER Eesnimi
    First name of the user.
.PARAMETER Perenimi
    Last name of the user.
.PARAMETER OUPath
    The Active Directory OU path where the user will be created. Default: 'OU=Kasutajad,DC=pehap,DC=local'.
.PARAMETER PasswordLength
    Length of the generated password. Default: 12.
#>
param(
    [Parameter(Mandatory=$true)][string]$Eesnimi,
    [Parameter(Mandatory=$true)][string]$Perenimi,
    [Parameter(Mandatory=$false)][string]$OUPath = 'OU=Kasutajad,DC=pehap,DC=local',
    [Parameter(Mandatory=$false)][int]$PasswordLength = 12
)

# Ensure ActiveDirectory module is available
Import-Module ActiveDirectory -ErrorAction Stop

# Build username, UPN and full name
$kasutajanimi = ($Eesnimi.Substring(0,1) + $Perenimi).ToLower()
$upn          = "$kasutajanimi@pehap.local"
$taisnimi     = "$Eesnimi $Perenimi"

# Check existence of the user
if (Get-ADUser -Filter { SamAccountName -eq $kasutajanimi }) {
    Write-Error "User '$kasutajanimi' already exists."
    exit 0
}

# Function to generate a strong password with complexity requirements
function Generate-StrongPassword {
    param(
        [Parameter(Mandatory=$true)][int]$Length
    )
    Add-Type -AssemblyName System.Web
    $attempt = 0
    do {
        if ($attempt -ge 10) {
            throw "Unable to generate a compliant password after $attempt attempts."
        }
        $attempt++
        # GeneratePassword(length, numberOfNonAlphanumericChars)
        $newPassword = [System.Web.Security.Membership]::GeneratePassword($Length, 2)
    } while (
        $newPassword -notmatch '[A-Z]' -or
        $newPassword -notmatch '[a-z]' -or
        $newPassword -notmatch '\d'   -or
        $newPassword -notmatch '[^\w]'
    )
    return $newPassword
}

# Generate and secure the password
try {
    $parool = Generate-StrongPassword -Length $PasswordLength
} catch {
    Write-Error $_
    exit 1
}

# Create the AD user
New-ADUser \
    -SamAccountName      $kasutajanimi \
    -UserPrincipalName   $upn \
    -Name                $taisnimi \
    -GivenName           $Eesnimi \
    -Surname             $Perenimi \
    -AccountPassword     (ConvertTo-SecureString $parool -AsPlainText -Force) \
    -Path                $OUPath \
    -Enabled             $true \
    -ChangePasswordAtLogon $true

# Report outcome
if ($?) {
    Write-Host "User '$kasutajanimi' created successfully with password: $parool"
    exit 0
} else {
    Write-Error "Failed to create user '$kasutajanimi'."
    exit 1
}
