param(
    [string]$ddnsFile,
    [string]$port
)

if (-not (Test-Path $ddnsFile)) {
    Write-Host "Arquivo de DDNS não encontrado!" -ForegroundColor Red
    exit
}

$ddns = Get-Content $ddnsFile

Add-Type -AssemblyName System.Windows.Forms

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

while($true) {
    $results = @()

    foreach ($tcpserveraddress in $ddns) {
        $currentTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
        Write-Host -NoNewline "`r$currentTime - Verificação DDNS:" -ForegroundColor Green
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
            # Exibe uma mensagem de aviso
            [System.Windows.Forms.MessageBox]::Show("O DDNS $tcpserveraddress está inativo!", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }

        $results += [PSCustomObject]@{
            DDNS = $tcpserveraddress
            Port = $port
            Status = $status
        }
    }

    $results | Format-Table -AutoSize -Property DDNS, Port, Status

    Write-Host "`nAguardando próximo ciclo de verificação`n" -ForegroundColor Yellow
    Start-Sleep -Seconds 300
}