#Loo uus skript, mis palub kasutaja sisestada kasutaja ees- ja perenimi, keda on vaja kustutada AD-st. 

# Palub kasutajal sisestada eesnimi ja perenimi
	$Eesnimi = Read-Host "Sisestage kasutaja eesnimi (ainult ladina tähed)"
	$Perenimi = Read-Host "Sisestage kasutaja perenimi (ainult ladina tähed)"

# Loob täisnime ees- ja perekonnanimest
	$FullName = "$Eesnimi $Perenimi"

# Määrab kasutajanime
	$Kasutajanimi = "$Eesnimi.$Perenimi"

# Kontrollib, kas kasutaja on AD-s olemas
	$User = Get-ADUser -Filter {SamAccountName -eq $Kasutajanimi}

	if ($User) {
    # Kui kasutaja on olemas, kustutab kasutaja
	    Remove-ADUser -Identity $User
	    Write-Host "Kasutajakonto $FullName on edukalt kustutatud AD-st."
	} else {
    # Kui kasutajat ei leita, kuvab teate
	    Write-Host "Kasutajakonto $FullName ei leitud AD-st."
	}
