# Küsib kasutaja ees- ja perenime, lubades ainult ladina tähti
$eesnimi = Read-Host "Sisesta eesnimi (ainult ladina tähed)"
if ($eesnimi -notmatch '^[A-Za-z]+$') {
    Write-Error "Eesnimi peab sisaldama ainult ladina tähti."
    exit 1
}

$perenimi = Read-Host "Sisesta perenimi (ainult ladina tähed)"
if ($perenimi -notmatch '^[A-Za-z]+$') {
    Write-Error "Perenimi peab sisaldama ainult ladina tähti."
    exit 1
}

# Koosta kasutajanimi väikeste tähtedega
$kasutajanimi = ("{0}.{1}" -f $eesnimi, $perenimi).ToLower()

# Koosta täisnimi ja kasutajanimi koos domeeniga (UPN)
$taisu_nimi = "$eesnimi $perenimi"
$domeen = 'pehap.local'
$upn = "$kasutajanimi@$domeen"

# Kontrolli, kas kasutaja on juba olemas AD-s
try {
    $on_olemas = Get-ADUser -Filter "SamAccountName -eq '$kasutajanimi'" -ErrorAction Stop
} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    $on_olemas = $null
} catch {
    Write-Error "Viga AD päringul: $_"
    exit 1
}

if ($on_olemas) {
    Write-Host "Kasutaja '$taisnimi' (kasutajanimi: $kasutajanimi) on juba olemas AD-s."
    exit 0
}

# Küsib algse parooli
$parool = Read-Host "Sisesta kasutaja algne parool" -AsSecureString

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
