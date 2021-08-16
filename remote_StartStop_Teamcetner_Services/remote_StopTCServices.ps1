<#
.SYNOPSIS
   remote_StopTCServices
.DESCRIPTION
   The small script to shotdown Services of Teamcenter on the remote servers
.PARAMETER <paramName>
    It uses remoteStartStop_config.xml configuration file
.AUTHOR
   alexey.sedoykin@siemens.com
#>


#считываем исходные данные из конфигурационного xml-я
[xml]$xmlConfig = Get-Content -Path .\remoteStartStop_config.xml

#подготовка данных для авторизации на smtp
$passwd = ConvertTo-SecureString $xmlConfig.Config.SystemData.SMTPPass -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($xmlConfig.Config.SystemData.SMTPLogin, $passwd)

<#пройдем по xml и сформируем правильный Get-Service #>
<#идём по Server-ам перечисленным в xml #>
For ($i=0; $i -lt $xmlConfig.selectnodes("//Server").Count; $i++) 
{
        $nodesService=$xmlConfig.Config.Server[$i].ServiceInternalName.Count
        <#идём по Servcice-ам#>
        For ($j=0; $j -lt $nodesService; $j++) 
        {
           $serviceName=$xmlConfig.Config.Server[$i].ServiceInternalName[$j] 
        
           $inputParametersGetService = @{
                Name = $serviceName.InnerText
                ComputerName=$xmlConfig.Config.Server[$i].name 
            }

           #запрос состояния служб на удаленных серверах
           Get-Service @inputParametersGetService
        
        }  
}

#вводы времени, конвертация из строки в число и высчитывание смещения от текущего времени
Write-Host ""
[uint16]$stopTimeAfterMinutes = Read-Host -Prompt "Через сколько минут остановить бизнес-логику и сопутствующие службы?"
$stopTimeAfterSeconds=$stopTimeAfterMinutes*[uint16]60
$timeToStop=(Get-Date).AddMinutes($stopTimeAfterMinutes).ToString("HH:mm")

#отправка письма пользователям
Send-MailMessage `
-SmtpServer $xmlConfig.Config.SystemData.SMTPServer.ToString() `
-Port 25 `
-Credential $creds `
-To $xmlConfig.Config.SystemData.MailTo.ToString() `
-From $xmlConfig.Config.SystemData.MailFrom.ToString() `
-Subject "Отключение Teamcenter" `
-Body "Уважаемые пользователи, Teamcenter будет остановлен в $timeToStop местного времени" `
-Encoding 'UTF8'

<#пройдем по xml и сформируем правильный Get-Service #>
<#идём по Server-ам перечисленным в xml #>
For ($i=0; $i -lt $xmlConfig.selectnodes("//Server").Count; $i++) 
{
        $nodesService=$xmlConfig.Config.Server[$i].ServiceInternalName.Count
        <#идём по Servcice-ам#>
        For ($j=0; $j -lt $nodesService; $j++) 
        {
           $serviceName=$xmlConfig.Config.Server[$i].ServiceInternalName[$j] 
        
           $inputParametersGetService = @{
                Name = $serviceName.InnerText
                ComputerName=$xmlConfig.Config.Server[$i].name 
            }

           #остановка служб на удаленных серверах
           Get-Service @inputParametersGetService | Stop-Service -Force
        
        }  
}

Write-Host ""
#запрос состояния служб на удаленных серверах
Write-Host "Службы остановлены"
Write-Host ""
<#пройдем по xml и сформируем правильный Get-Service #>
<#идём по Server-ам перечисленным в xml #>
For ($i=0; $i -lt $xmlConfig.selectnodes("//Server").Count; $i++) 
{
        $nodesService=$xmlConfig.Config.Server[$i].ServiceInternalName.Count
        <#идём по Servcice-ам#>
        For ($j=0; $j -lt $nodesService; $j++) 
        {
           $serviceName=$xmlConfig.Config.Server[$i].ServiceInternalName[$j] 
        
           $inputParametersGetService = @{
                Name = $serviceName.InnerText
                ComputerName=$xmlConfig.Config.Server[$i].name 
            }

           #запрос состояния служб на удаленных серверах
           Get-Service @inputParametersGetService
        
        }  
}
Write-Host ""

#ждём нажатия любой клавиши для выхода
write-host -nonewline "Нажмите любую клавишу для завершения работы"
$response = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
if ( $response -ne "" ) 
{ 
exit 
}

