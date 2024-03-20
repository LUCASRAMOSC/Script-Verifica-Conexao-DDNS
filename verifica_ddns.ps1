param(
    [string]$ddnsFile,
    [string]$port
)

if (-not (Test-Path $ddnsFile)) {
    Write-Host "Arquivo de DDNS não encontrado!" -ForegroundColor Red
    exit
}

$ddns = Get-Content $ddnsFile
$statusAnterior = @{}  # Dicionário para armazenar o status anterior de cada DDNS

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
        }

        # Verifica se o status atual é diferente do status anterior
        if ($status -ne $statusAnterior[$tcpserveraddress]) {
            if ($status -eq "Inativo") {
                # Exibe uma mensagem de aviso apenas se o DDNS estiver inativo no ciclo atual
                [System.Windows.Forms.MessageBox]::Show("O DDNS $tcpserveraddress está inativo!", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            } else {
                # Exibe uma mensagem de notificação se o DDNS mudar de inativo para ativo
                [System.Windows.Forms.MessageBox]::Show("O DDNS $tcpserveraddress está ativo novamente!", "Notificação", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
            # Atualiza o status anterior com o status atual
            $statusAnterior[$tcpserveraddress] = $status
        }

        $results += [PSCustomObject]@{
            DDNS = $tcpserveraddress
            Port = $port
            Status = $status
        }
    }

    $results | Format-Table -AutoSize -Property DDNS, Port, Status

    Write-Host "`nAguardando próximo ciclo de verificação`n" -ForegroundColor Yellow
    Start-Sleep -Seconds 5
}