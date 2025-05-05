# Lokaalse kasutaja kustutamine ees- ja perenime kaudu
# Palub kasutajal sisestada eesnimi ja perenimi
	$Eesnimi = Read-Host "Sisestage kasutaja eesnimi (ainult ladina tähed)"
	$Perenimi = Read-Host "Sisestage kasutaja perenimi (ainult ladina tähed)"

# Loob täisnime ees- ja perekonnanimest
	$FullName = "$Eesnimi $Perenimi"

# Leiab kasutajanime täisnime alusel (võib eeldada, et kasutajanimi on ees- ja perekonnanimi)
	$Kasutajanimi = "$Eesnimi.$Perenimi"

# Kustutab kohaliku kasutaja
	Remove-LocalUser -Name $Kasutajanimi

# Teavitab kasutajat, et konto on kustutatud
	Write-Host "Kasutajakonto $FullName on edukalt kustutatud."
