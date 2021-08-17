<#
.SYNOPSIS
   PolarionBackup
.DESCRIPTION
   The small script to create a backup the Polarion data and move it to the Azure storage
.AUTHOR
   alexey.sedoykin@siemens.com
#>

$PolarionPath="C:\Polarion"

net use Z: \\archivesbackups.file.................


Get-Service -Name Apache2Polarion | Stop-Service -Force
Get-Service -Name Polarion | Stop-Service -Force
Get-Service -Name PolarionSvnserve | Stop-Service -Force
Get-Service -Name PostgreSQLPolarion | Stop-Service -Force

Get-ChildItem -Path $PolarionPath\data\logs\apache -Include *.* -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -Path $PolarionPath\data\logs\derby -Include *.* -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -Path $PolarionPath\data\logs\install -Include *.* -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -Path $PolarionPath\data\logs\main -Include *.* -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -Path $PolarionPath\data\logs\postgresql -Include *.* -File -Recurse | foreach { $_.Delete()}

$ArchiveTime = Get-Date -Format "dd_MM_yyyy_HH_mm"
$ArchiveFile = 'C:\'+$ArchiveTime+"_PolarionData.7z"

$7zip = "$env:ProgramFiles\7-Zip\7z.exe"
Set-Alias -Name 7zip -Value $7zip

7zip a -r -mx=9 $ArchiveFile "$PolarionPath\data"

&svnadmin pack "$PolarionPath\data\svn\repo\"

Move-Item $ArchiveFile z:\polarionbackups 

net start "Apache2Polarion"
net start "Polarion"
net start "PolarionSvnserve"
net start "PostgreSQLPolarion"

Send-MailMessage `
-SmtpServer 'YouSMTPServer.bigcompany.ru' `
-Port 25 `
-To 'MegaADmin@bigcompany.ru' `
-From 'yourlovelypolarion@bigcompany.ru' `
-Subject "Резервное копирование Polarion" `
-Body "Была создана резеврная копия $ArchiveFile" `
-Encoding 'UTF8'

Get-Service -Name Apache2Polarion | Set-Service -Status Running
Get-Service -Name Polarion | Set-Service -Status Running
Get-Service -Name PolarionSvnserve | Set-Service -Status Running
Get-Service -Name PostgreSQLPolarion | Set-Service -Status Running






