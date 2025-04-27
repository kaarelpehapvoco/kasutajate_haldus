$eesnimi = Read-Host "Sisesta eesnimi (ainult ladina tähed)"
$perenimi = Read-Host "Sisesta perenimi (ainult ladina tähed)"

# Loo kasutajanimi väikeste tähtedega
$kasutajanimi = ("{0}.{1}" -f $eesnimi, $perenimi).ToLower()

# Kasutaja täisnimi ja kirjeldus
$fullname = "$eesnimi $perenimi"

# Proovime luua kasutaja
try {
    New-LocalUser -Name $kasutajanimi -Password (ConvertTo-SecureString "Parool1!" -AsPlainText -Force) -FullName $fullname -ErrorAction Stop
    if ($?) {
        Write-Output "Kasutaja '$kasutajanimi' loodud edukalt."
    }
} catch {
    Write-Output "Viga kasutaja loomisel: $_"
}