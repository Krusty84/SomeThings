<#
.SYNOPSIS
   SetNetworkRules
.DESCRIPTION
   The small script for the set in automaticaly mode networking rules
.PARAMETER <paramName>
   -SubscriptionId  ---- need to get the right value from your azure portal
.AUTHOR
   alexey.sedoykin@siemens.com
#>

Connect-AzAccount

Set-AzContext -SubscriptionId blablabla-blab-1111-2222-1123123123123

$AvaliableVMS=Get-AzVM | Select-Object -Property Name

Write-Host "VM доступные вам" -ForegroundColor Green -BackgroundColor Black

for ($i=0; $i -lt $AvaliableVMS.Count; $i++)
{
   Write-Host "[" $i "]" " " $AvaliableVMS[$i].Name

}
Write-Host "Укажите номер конфигурируемой VM"  -ForegroundColor Green -BackgroundColor Black
$ChosenVMconfirmation = Read-Host
Write-Host "Подтвердите номер конфигурируемой VM" -ForegroundColor Red -BackgroundColor Black
$ChosenVMsecondconfirmation = Read-Host
If ($ChosenVMconfirmation -eq $ChosenVMsecondconfirmation)
{
	$ChosenVM=$ChosenVMconfirmation
	Write-Host "Будет осуществленно конфигурирование VM " $AvaliableVMS[$ChosenVM].Name
}else{
	Write-Host "Лучше не торопиться и подумать, да"
	Start-Sleep -Seconds 5
	exit
}

#открываем типовые порты Teamcenter и Co для досутпа по WAN
$NgsFullString=(Get-AzNetworkInterface -ResourceId (Get-AzVM -Name $AvaliableVMS[$ChosenVM].Name).NetworkProfile.NetworkInterfaces.Id).NetworkSecurityGroup.Id
$TempArrayForParsing = $NgsFullString.Split("/")
$Ngs=$tempArrayForParsing[$TempArrayForParsing.Count-1]
$Ngs
Get-AzNetworkSecurityGroup -Name $Ngs -ResourceGroupName (Get-AzVM -Name $AvaliableVMS[$ChosenVM].Name).ResourceGroupName | Add-AzNetworkSecurityRuleConfig -Name "TC_Ports_WAN" -Description "Teamcenter Ports that will be opened for WAN" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange (4544,7001,3000) | Set-AzNetworkSecurityGroup

#открываем типовые порты Teamcenter и Co для доступа через VPN - BananaCountry
Get-AzNetworkSecurityGroup -Name $Ngs -ResourceGroupName (Get-AzVM -Name $AvaliableVMS[$ChosenVM].Name).ResourceGroupName | Add-AzNetworkSecurityRuleConfig -Name "VPN_BananaCountry" -Description "Teamcenter and Various Ports that will be opened for BananaCountry VPN" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 101 -SourceAddressPrefix "1.2.3.4/24" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange (80,443,3389,4544,7001,3000) | Set-AzNetworkSecurityGroup

Write-Host "Не забудьте настроить Firewall в VM, испльзуйте скрипт SetFirewallRules.bat" -ForegroundColor Magenta -BackgroundColor Black