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

$currentHomeIp = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
Connect-AzAccount

#задайте Subscription ID вашей подписки в Azure
Set-AzContext -SubscriptionId blablabla-blab-1111-2222-1123123123123

$AvaliableVMS = Get-AzVM | Select-Object -Property Name

Write-Host "VM доступные вам" -ForegroundColor Green -BackgroundColor Black

for ($i = 0; $i -lt $AvaliableVMS.Count; $i++) {
    Write-Host "[" $i "]" " " $AvaliableVMS[$i].Name

}
Write-Host "Укажите номер конфигурируемой VM"  -ForegroundColor Green -BackgroundColor Black
$ChosenVMconfirmation = Read-Host
Write-Host "Подтвердите номер конфигурируемой VM" -ForegroundColor Red -BackgroundColor Black
$ChosenVMsecondconfirmation = Read-Host
If ($ChosenVMconfirmation -eq $ChosenVMsecondconfirmation) {
    $ChosenVM = $ChosenVMconfirmation
    Write-Host "Будет осуществленно конфигурирование VM " $AvaliableVMS[$ChosenVM].Name
}
else {
    Write-Host "Лучше не торопиться и подумать, да"
    Start-Sleep -Seconds 5
    exit
}
######
Write-Host "Разрешить доступ с вашего текущего IP адреса (Y/N): " $currentHomeIp  -ForegroundColor Green -BackgroundColor Black
$ChosenHomeIPconfirmation = Read-Host

if ($ChosenHomeIPconfirmation -eq 'y') {
    $Config4PrivateIP = 1;
}
else {
    $Config4PrivateIP = 0;
}
Write-Host "Дождитесь завершения работы скрипта, не закрывайте это окно!" -ForegroundColor White -BackgroundColor Blue
######
##Цепляемся к сетевому адаптеру, получаем Security Group и пр
$ResourceGroupName = (Get-AzVM -Name  $AvaliableVMS[$ChosenVM].Name).ResourceGroupName;
$ChosenVMNow = Get-AzVM -Name  $AvaliableVMS[$ChosenVM].Name;

#сколько сетевых адаптеров у VM
if ($ChosenVMNow.NetworkProfile.NetworkInterfaces.Count -gt 1) {
    $NicName = ($ChosenVMNow.NetworkProfile.NetworkInterfaces | Where-Object Primary -eq $true).Id.Split('/') | Select-Object -Last 1
}
else {
    $NicName = $ChosenVMNow.NetworkProfile.NetworkInterfaces.Id.Split('/') | Select-Object -Last 1
}
$NickNSGName = (Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NicName).NetworkSecurityGroup.Id.Split('/') | Select-Object -Last 1
$NicNsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Name $NickNSGName
######

#закроемся явным образом
$NicNsg | Add-AzNetworkSecurityRuleConfig -Name "TC_Ports_WAN" -Description "Teamcenter Ports that will be opened for WAN" -Access "Deny" -Protocol "Tcp" -Direction "Inbound" -Priority 500 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange (80, 443, 3389, 4544, 7001, 3000, 5201) | Set-AzNetworkSecurityGroup

#открываем типовые порты Teamcenter и Co для доступа через VPN - BananaCountry
Get-AzNetworkSecurityGroup -Name $Ngs -ResourceGroupName (Get-AzVM -Name $AvaliableVMS[$ChosenVM].Name).ResourceGroupName | Add-AzNetworkSecurityRuleConfig -Name "VPN_BananaCountry" -Description "Teamcenter and Various Ports that will be opened for BananaCountry VPN" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 101 -SourceAddressPrefix "1.2.3.4/24" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange (80, 443, 3389, 4544, 7001, 3000, 5201) | Set-AzNetworkSecurityGroup


if ($Config4PrivateIP -eq 1) {
    #открываем типовые порты Teamcenter и Co для доступа c домашнего IP
    $NicNsg | Add-AzNetworkSecurityRuleConfig -Name "TC_Ports_ForAccessFrom_HOME" -Description "Teamcenter and Various Ports that will be opened for SaoCaetano VPN" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 111 -SourceAddressPrefix $currentHomeIp -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange (80, 443, 3389, 4544, 7001, 3000, 5201) | Set-AzNetworkSecurityGroup
    #
    Write-Host "Если VM Была создана не на базе: Windows_2016_Oracle19c_Tomcat_Java8_202, то не забудьте настроить Firewall в VM, испльзуйте скрипт SetFirewallRules.bat" -ForegroundColor Magenta -BackgroundColor Black
}
else {
    Write-Host "Если VM Была создана не на базе: Windows_2016_Oracle19c_Tomcat_Java8_202, то не забудьте настроить Firewall в VM, испльзуйте скрипт SetFirewallRules.bat" -ForegroundColor Magenta -BackgroundColor Black
}

Write-Host -NoNewLine 'Нажмите любую клавишу для завершения работы...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
