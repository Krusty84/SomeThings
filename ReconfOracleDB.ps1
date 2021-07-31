<#
.SYNOPSIS
   ReconfOracleDB
.DESCRIPTION
   The small script for changed the host name in the tnsnames.ora and listener.ora
.PARAMETER <paramName>
.AUTHOR
   alexey.sedoykin@siemens.com
#>

$CurrentHOSTName = [System.Net.DNS]::GetHostByName('').HostName
if ($CurrentHOSTName -eq "ChangeThisName"){
	Write-Host "Ваша VM имеет сетевое имя по умолчанию - ChangeThisName, ИЗМЕНИТЕ его!" -ForegroundColor Magenta -BackgroundColor Black
	Write-Host "Изменить сетевое имя?" -ForegroundColor Green -BackgroundColor Black
	
	$reply = Read-Host -Prompt "[y/n]"
	if ( $reply -match "[yY]" ) { 
		$NewComputerName = Read-Host "Введите новое имя для этой VM (не более 15 символов)"
		while($NewComputerName.length -gt 15)
		{
				$NewComputerName = Read-Host "Введите новое имя для этой VM (не более 15 символов)"
		}
		
		Rename-Computer -NewName $NewComputerName
		
	Stop-Service -Name "OracleServiceTC"
	Stop-Service -Name "OracleOraDB19Home1TNSListener"
	$TNSNamesContent = Get-Content -Path 'c:\Oracle\network\admin\tnsnames.ora'
	$ListenerContent = Get-Content -Path 'c:\Oracle\network\admin\listener.ora'
	$newTNSNamesContent = $TNSNamesContent -replace 'ChangeThisName', $NewComputerName
	$newListenerContent = $ListenerContent -replace 'ChangeThisName', $NewComputerName
	$newTNSNamesContent | Set-Content -Path 'c:\Oracle\network\admin\tnsnames.ora'
	$newListenerContent | Set-Content -Path 'c:\Oracle\network\admin\listener.ora'
	Write-Host "Конфигурационные файлы Oracle - изменены" -ForegroundColor Green -BackgroundColor Black
	Start-Sleep -Seconds 5
	Start-Service -Name "OracleOraDB19Home1TNSListener"
	Start-Sleep -Seconds 5
	Start-Service -Name "OracleServiceTC"
	Write-Host "Перезагрузите VM" -ForegroundColor Green -BackgroundColor Black
	Start-Sleep -Seconds 5
	} else {
		exit
	}
}else{
	Write-Host "Возможно вы уже изменили сетевое имя у этой VM, скрипт на всякий случай переконфигурирует Oracle" -ForegroundColor Green -BackgroundColor Black
	Stop-Service -Name "OracleServiceTC"
	Stop-Service -Name "OracleOraDB19Home1TNSListener"
	$TNSNamesContent = Get-Content -Path 'c:\Oracle\network\admin\tnsnames.ora'
	$ListenerContent = Get-Content -Path 'c:\Oracle\network\admin\listener.ora'
	$newTNSNamesContent = $TNSNamesContent -replace 'ChangeThisName', [System.Net.DNS]::GetHostByName('').HostName
	$newListenerContent = $ListenerContent -replace 'ChangeThisName', [System.Net.DNS]::GetHostByName('').HostName
	$newTNSNamesContent | Set-Content -Path 'c:\Oracle\network\admin\tnsnames.ora'
	$newListenerContent | Set-Content -Path 'c:\Oracle\network\admin\listener.ora'
	Write-Host "Конфигурационные файлы Oracle - изменены" -ForegroundColor Green -BackgroundColor Black
	Start-Sleep -Seconds 5
	Start-Service -Name "OracleOraDB19Home1TNSListener"
	Start-Sleep -Seconds 5
	Start-Service -Name "OracleServiceTC"
	Write-Host "Перезагрузите VM" -ForegroundColor Green -BackgroundColor Black
	Start-Sleep -Seconds 5
}
