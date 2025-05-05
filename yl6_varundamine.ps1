# Koosta skript, mis kontrollib kõikide kasutajate olemasolu süsteemis ja igale kasutajale loob tema kodukataloogi varundus, mille paigutad C:\Backup kausta.

# Loob varunduse kausta, kui see ei eksisteeri
$BackupPath = "C:\Backup"
if (-Not (Test-Path -Path $BackupPath)) {
    New-Item -Path $BackupPath -ItemType Directory
}

# Varundus lokaalsete kasutajate jaoks
$Users = Get-LocalUser

foreach ($User in $Users) {
    if ($User.Enabled -eq $true) {
        $UserProfilePath = "C:\Users\$($User.Name)"
        if (Test-Path -Path $UserProfilePath) {
            # Loob varunduse kausta kasutaja jaoks
            $UserBackupPath = "$BackupPath\$($User.Name)"
            if (-Not (Test-Path -Path $UserBackupPath)) {
                New-Item -Path $UserBackupPath -ItemType Directory
            }

            # Kopeerib kasutaja kodukataloogi varunduse kausta
            Copy-Item -Path "$UserProfilePath\*" -Destination $UserBackupPath -Recurse

            Write-Host "Varundus loodud kasutajale: $($User.Name)"
        } else {
            Write-Host "Kasutaja kodukataloogi ei leitud: $($User.Name)"
        }
    } else {
        Write-Host "Kasutaja on keelatud: $($User.Name)"
    }
}
