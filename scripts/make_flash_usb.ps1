<#
.SYNOPSIS
    Prepara um pendrive FAT32 para o flash da BIOS modificada da AMD BC-250.

.DESCRIPTION
    Baixa (ou reutiliza) o kit EFI e a ROM modificada P3.00, verifica os hashes
    SHA256 publicados pela comunidade e monta a RAIZ do pendrive com:

        Robin5.00       -> a ROM mod P3.00 (verificada), renomeada
        Flash.nsh       -> script de flash (AfuEfix64.efi Robin5.00 /p /b /n /k /x /rlc:e)
        AfuEfix64.efi   -> utilitario AMI de flash
        amdvbflash.efi  -> utilitario auxiliar
        EFI\BOOT\       -> shell embutido (o pendrive boota direto no EFI Shell)
        recuperacao\    -> stock P3.00 verificada (imagem de recuperacao)

    O script NAO formata o pendrive e NAO apaga nada: exige que ele ja esteja
    em FAT32 e apenas adiciona/sobrescreve os arquivos do kit na raiz.

.PARAMETER DriveLetter
    Letra do pendrive (ex.: I). Omita para detectar automaticamente um USB
    removivel em FAT32 com 8 GB ou mais.

.PARAMETER WorkDir
    Pasta de trabalho para downloads/extracao. Padrao: .\bc250-flash-kit

.EXAMPLE
    .\make_flash_usb.ps1 -DriveLetter I

.NOTES
    Risco: flash de BIOS tem risco real de brick. Leia o guia antes de executar:
    https://github.com/phantomwar/bc250-cachyos-gaming
#>
[CmdletBinding()]
param(
    [string]$DriveLetter = "",
    [string]$WorkDir = ".\bc250-flash-kit"
)

$ErrorActionPreference = 'Stop'

# --- Hashes oficiais (comunidade BC-250, multi-fonte) ------------------------
$HASH_MOD_ROM  = '48fbe5d366e6a56e2fdffdca848426216ba1f083610dab63db89d2f4e6c940b5' # BC250_3.00_CHIPSETMENU.ROM (mod, recomendada)
$HASH_STOCK_P3 = '07595ca3aecf8a4caa28a397b5298f3946a1b769f87b16f67adc369c3f69045c' # BC250_3.00.ROM (stock, recuperacao)
$HASH_STOCK_P5 = '0d6f136cb120cf3b2de26d5c4d7f255604fdbf4b9442af5ba55419b95b89aa82' # Robin5.00 (stock P5.00, embutido no kit)

$URL_KIT = 'https://github.com/kenavru/BC-250/raw/refs/heads/main/4U12G%20BIOS%20Update.zip'
$URL_MOD = 'https://gitlab.com/TuxThePenguin0/bc250-bios/-/raw/main/BC250_3.00_CHIPSETMENU.ROM'
$URL_P3  = 'https://gitlab.com/TuxThePenguin0/bc250-bios/-/raw/main/BC250_3.00.ROM'

function Write-Step { param($m) Write-Host "`n==> $m" -ForegroundColor Cyan }
function Write-Ok   { param($m) Write-Host "    OK  $m" -ForegroundColor Green }

function Assert-Hash {
    param([string]$Path, [string]$Expected, [string]$Label)
    $h = (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLower()
    if ($h -ne $Expected) {
        throw "FALHA DE HASH em '$Label': $h (esperado $Expected). NAO USE este arquivo."
    }
    Write-Ok "$Label - SHA256 verificado"
}

# --- 1) Pendrive --------------------------------------------------------------
Write-Step 'Identificando o pendrive'
if (-not $DriveLetter) {
    $usb = Get-CimInstance Win32_DiskDrive |
        Where-Object { $_.InterfaceType -eq 'USB' -or $_.Model -match 'USB' } |
        ForEach-Object {
            Get-Partition -DiskNumber $_.Index -ErrorAction SilentlyContinue |
                Get-Volume -ErrorAction SilentlyContinue |
                Where-Object { $_.FileSystem -eq 'FAT32' -and $_.DriveLetter -and $_.Size -gt 8GB }
        } | Select-Object -First 1
    if (-not $usb) { throw 'Nenhum pendrive FAT32 (>=8 GB) encontrado. Conecte um ou informe -DriveLetter.' }
    $DriveLetter = $usb.DriveLetter
}
if ($DriveLetter -ieq 'C') { throw 'Recusado: nao se aplica a unidade do sistema.' }
$drive = Get-Volume -DriveLetter $DriveLetter -ErrorAction Stop
if ($drive.FileSystem -ne 'FAT32') {
    throw "O drive $($DriveLetter): esta em $($drive.FileSystem), nao FAT32. Formate em FAT32 e rode novamente."
}
Write-Ok "Drive $($DriveLetter): FAT32, $([math]::Round($drive.Size/1GB,2)) GB, rotulo '$($drive.FileSystemLabel)'"

# --- 2) Downloads + verificacao ------------------------------------------------
Write-Step 'Baixando/validando arquivos (hashes da comunidade)'
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
$kitZip = Join-Path $WorkDir '4U12G BIOS Update.zip'
$modRom = Join-Path $WorkDir 'BC250_3.00_CHIPSETMENU.ROM'
$p3Rom  = Join-Path $WorkDir 'BC250_3.00.ROM'

if (-not (Test-Path $kitZip)) { Invoke-WebRequest -Uri $URL_KIT -OutFile $kitZip -UseBasicParsing }
if (-not (Test-Path $modRom)) { Invoke-WebRequest -Uri $URL_MOD -OutFile $modRom -UseBasicParsing }
if (-not (Test-Path $p3Rom))  { Invoke-WebRequest -Uri $URL_P3  -OutFile $p3Rom  -UseBasicParsing }

Assert-Hash -Path $modRom -Expected $HASH_MOD_ROM  -Label 'ROM mod P3.00 (BC250_3.00_CHIPSETMENU.ROM)'
Assert-Hash -Path $p3Rom  -Expected $HASH_STOCK_P3 -Label 'ROM stock P3.00 (recuperacao)'

$kitDir = Join-Path $WorkDir 'kit'
Expand-Archive -Path $kitZip -DestinationPath $kitDir -Force
$kitBiosEfi = Get-ChildItem $kitDir -Recurse -Directory |
    Where-Object { $_.Name -ieq 'BIOS EFI' } | Select-Object -First 1
if (-not $kitBiosEfi) { throw 'Estrutura inesperada do kit: pasta "BIOS EFI" nao encontrada.' }
$kitStock = Join-Path $kitBiosEfi.FullName 'Robin5.00'
if (Test-Path $kitStock) {
    Assert-Hash -Path $kitStock -Expected $HASH_STOCK_P5 -Label 'stock P5.00 embutido no kit (valida o kit inteiro)'
}

# --- 3) Montagem da raiz (sem apagar nada) --------------------------------------
Write-Step 'Montando a raiz do pendrive'
$root = "$($DriveLetter):\"

# A ROM mod verificada vira Robin5.00 na raiz (nome que o Flash.nsh espera)
Copy-Item $modRom (Join-Path $root 'Robin5.00') -Force
Write-Ok 'Robin5.00 = mod P3.00 verificada'

# Ferramentas do kit na raiz, EXCETO o stock Robin5.00 do kit (evita flash do arquivo errado)
Get-ChildItem $kitBiosEfi.FullName -File |
    Where-Object { $_.Name -ine 'Robin5.00' } |
    ForEach-Object { Copy-Item $_.FullName $root -Force; Write-Ok "copiado: $($_.Name)" }
Get-ChildItem $kitBiosEfi.FullName -Directory |
    ForEach-Object { Copy-Item $_.FullName $root -Recurse -Force; Write-Ok "copiado: $($_.Name)\" }

# Imagem de recuperacao em subpasta (FORA da raiz, para nunca ser flasheada por engano)
New-Item -ItemType Directory -Force -Path (Join-Path $root 'recuperacao') | Out-Null
Copy-Item $p3Rom (Join-Path $root 'recuperacao\BC250_3.00.ROM') -Force
Write-Ok 'recuperacao\BC250_3.00.ROM (stock P3.00 verificada)'

# --- 4) Relatorio final ----------------------------------------------------------
Write-Step 'Raiz final do pendrive'
Get-ChildItem $root -Force | Select-Object Name, Length | Format-Table -AutoSize

Write-Host 'Pendrive pronto! Proximos passos (fisicos, na BC-250):' -ForegroundColor Yellow
Write-Host '  1. Desligue a BC-250 (shutdown completo) e desconecte os SSDs/drives'
Write-Host '  2. Conecte o pendrive e ligue -> prompt amarelo Shell>'
Write-Host '  3. Digite: fs0:  -> Enter; ls para conferir os arquivos; depois: flash-safe.nsh -> Enter (caminho validado em campo)'
Write-Host '  4. NAO toque/desligue. Ao reiniciar sozinho, desligue e remova o pendrive'
Write-Host '  5. CMOS clear: bateria CR2032 fora >= 60 s; reconfigure a BIOS (VRAM 512MB, IOMMU Disabled, UEFI)'
Write-Host ''
Write-Host 'Recuperacao, se necessario: copie recuperacao\BC250_3.00.ROM para a raiz' -ForegroundColor Yellow
Write-Host 'renomeada como Robin5.00 e repita o metodo USB.' -ForegroundColor Yellow
