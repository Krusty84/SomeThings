<#
.SYNOPSIS
   remote_StartTCServices
.DESCRIPTION
   The small script to run Services of Teamcenter on the remote servers
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

Write-Host ""
Write-Host "Остановленные службы будут запущены не закрывайте это окно" 

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

           #запуск служб на удаленных серверах
           Get-Service @inputParametersGetService | Set-Service -Status Running
        
        }  
}


#получаем текущую дату/время
$timeToReady=(Get-Date)
Start-Sleep -Seconds 10

#отправка письма пользователям
Send-MailMessage `
-SmtpServer $xmlConfig.Config.SystemData.SMTPServer.ToString() `
-Port 25 `
-Credential $creds `
-To $xmlConfig.Config.SystemData.MailTo.ToString() `
-From $xmlConfig.Config.SystemData.MailFrom.ToString() `
-Subject "Teamcenter доступен" `
-Body "Уважаемые пользователи, Teamcenter вернулся к работе в $timeToReady " `
-Encoding 'UTF8'


Write-Host ""
#запрос состояния служб на удаленных серверах
Write-Host "Службы запущены"
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