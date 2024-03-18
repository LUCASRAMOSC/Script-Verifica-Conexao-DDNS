param(
    [string]$ddnsFile,
    [string]$port
)

if (-not (Test-Path $ddnsFile)) {
    Write-Host "Arquivo de DDNS não encontrado!" -ForegroundColor Red
    exit
}

$ddns = Get-Content $ddnsFile

while($true) {
    $results = @()

    foreach ($tcpserveraddress in $ddns) {
        $currentTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
        Write-Host -NoNewline "`r$currentTime - Verificacao DDNS:" -ForegroundColor Green
        $tcnArgs = @{
            ComputerName = $tcpserveraddress
            Port = $port
            WarningAction = 'SilentlyContinue'
        }

        $result = Test-NetConnection @tcnArgs

        $status = if ($result.TcpTestSucceeded) {
            "Ativo"
        } else {
            "Inativo"
        }

        $results += [PSCustomObject]@{
            DDNS = $tcpserveraddress
            Port = $port
            Status = $status
        }
    }

    $results | Format-Table -AutoSize -Property DDNS, Port, Status

    Write-Host "`nAguardando proximo ciclo de verificacao`n" -ForegroundColor Yellow
    Start-Sleep -Seconds 300
}
