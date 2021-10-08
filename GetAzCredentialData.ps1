Connect-AzAccount
Get-AzSubscription

Write-Host -NoNewLine 'Нажмите любую клавишу для завершения работы...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');