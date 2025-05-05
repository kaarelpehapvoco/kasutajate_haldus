Function GenerateStrongPassword ([Parameter(Mandatory=$true)][int]$PasswordLenght)
{
Add-Type -AssemblyName System.Web
$PassComplexCheck = $false
do {
$newPassword=[System.Web.Security.Membership]::GeneratePassword($PasswordLenght,1)
If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
-and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
-and ($newPassword -match "[\d]") `
-and ($newPassword -match "[^\w]")
)
{
$PassComplexCheck=$True
}
} While ($PassComplexCheck -eq $false)
return $newPassword





}
  Write-Error "Viga AD päringul: $_"
    exit 1
}

if ($on_olemas) {
    Write-Host "Kasutaja '$taisnimi' (kasutajanimi: $kasutajanimi) on juba olemas AD-s."
    exit 0
}

# Küsib algse parooli
$parool = GenerateStrongPassword()

# AD kasutaja loomine
$ou_tee = 'OU=Kasutajad,DC=pehap,DC=local'  # Muuda

try {
    New-ADUser \
        -Name               $taisnimi \
        -GivenName          $eesnimi \
        -Surname            $perenimi \
        -SamAccountName     $kasutajanimi \
        -UserPrincipalName  $upn \
        -AccountPassword    $parool \
        -Enabled            $true \
        -Path               $ou_tee \
        -ChangePasswordAtLogon $true \
        -ErrorAction        Stop

    Write-Host "Kasutaja '$kasutajanimi' loodud edukalt AD-s." -ForegroundColor Green
} catch {
    Write-Error "Viga kasutaja loomisel: $_"
    exit 1
}
