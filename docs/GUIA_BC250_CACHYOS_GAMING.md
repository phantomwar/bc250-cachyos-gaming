# AMD BC-250 — Guia Completo: Instalação e Otimização para Games com CachyOS

> **O que é isto:** guia prático, passo a passo, para transformar a placa **ASRock AMD BC-250**
> (o APU reciclado do **PlayStation 5**, codinome *Cyan Skillfish* / gfx1013) em uma máquina de
> jogos em 1080p usando **CachyOS** (aqui grafado "CacheOS"). Inclui BIOS, ACPI (C-states/P-states),
> governor de GPU, unlock de 8 núcleos, unlock das 40 CUs, overclock e troubleshooting.
>
> **Data da pesquisa:** 2026-09-04 · **Idioma:** Português (Brasil)
>
> **Aviso importante:** todo o material foi correlacionado e baixado no diretório de trabalho.
> Flashear BIOS, destravar núcleos/CUs e fazer overclock tem **risco real de dano**. Leia tudo
> antes de executar. Resumo dos avisos-chave está na seção 12.

---

## Índice

1. [O que é a BC-250 e o que ela pode fazer](#1-o-que-é-a-bc-250-e-o-que-ela-pode-fazer)
2. [Pré-requisitos de hardware](#2-pré-requisitos-de-hardware)
3. [BIOS: flash da versão modificada](#3-bios-flash-da-versão-modificada)
4. [Configuração da BIOS (VRAM, IOMMU, etc.)](#4-configuração-da-bios)
5. [Instalação do CachyOS](#5-instalação-do-cachyos)
6. [Pós-instalação: governor, sensores, kernel e ACPI](#6-pós-instalação)
7. [ACPI: C-states e P-states (o "cache de ACPI")](#7-acpi-c-states-e-p-states)
8. [Otimização para games](#8-otimização-para-games)
9. [Unlock de 8 núcleos de CPU](#9-unlock-de-8-núcleos-de-cpu)
10. [Unlock das 40 CUs de GPU](#10-unlock-das-40-cus-de-gpu)
11. [Overclock (CPU e GPU)](#11-overclock)
12. [Avisos de segurança e riscos](#12-avisos-de-segurança-e-riscos)
13. [Troubleshooting](#13-troubleshooting)
14. [Scripts e ferramentas baixados](#14-scripts-e-ferramentas-baixados)
15. [Fontes: GitHub, Reddit, fóruns e YouTube](#15-fontes)

---

## 1. O que é a BC-250 e o que ela pode fazer

A **AMD BC-250** é uma placa **ex-mineradora** (pensada para Ethereum) que usa um APU de
PlayStation 5 "cortado". Com a comunidade e os drivers Linux, virou uma máquina gamer
surpreendentemente capaz e barata.

**Especificações principais:**

| Componente | Especificação |
|---|---|
| CPU | 6 núcleos Zen 2 a ~3.5 GHz (**os 8 núcleos são destraváveis**) |
| GPU | 24 Compute Units RDNA2 (codinome "Cyan Skillfish" / gfx1013) (**40 CUs destraváveis**) |
| Memória | 16 GB GDDR6 compartilhada (CPU + GPU) |
| Conectividade | 1× DisplayPort, 2× USB 3.0, 2× USB 2.0, 1× GbE, M.2 NVMe/SATA |
| Alimentação | Conector PCIe 8-pin, TDP ~220 W |

**Performance (com setup Linux correto):** compara com uma RX 6600 / GTX 1660 Ti; joga em
1080p em médio/alto; suporta ray tracing (limitado) e FSR (frame generation). Exemplos reportados:
Cyberpunk 2077 60–90 FPS (1080p, alto, FSR), Control 40 FPS com RT, DMC 5 100+ FPS.

> **⚠️ Só Linux para gráficos.** **Não existe driver de GPU para Windows.** Qualquer aceleração
> gráfica, jogos ou compute exige Linux. Outras limitações: sem encode/decode de vídeo por hardware
> (VCN bloqueado pela Sony — só software), áudio via DisplayPort pode falhar com alguns adaptadores,
> sem WiFi/Bluetooth embutido, e consumo ocioso alto (~50–80 W sem otimização).

> **⚠️ NUNCA use Smokeless_UMAF** nesta placa — pode causar **dano permanente**.

**Versões da placa:** a maioria é funcionalmente idêntica, mas há BIOS diferentes (P2.00, P3.00,
P4.00, P5.00). Todas podem ser flasheadas para o BIOS modificado da comunidade.

---

## 2. Pré-requisitos de hardware

- **Fonte:** conecte o **PCIe 8-pin** corretamente (confira o pinout 12V/GND; polaridade
  invertida queima a placa). PSU ≥ 250 W no trilho 12 V para overclock.
- **Refrigeração:** o dissipador de fábrica precisa de melhorias (ventoinha de alta pressão
  estática, tipo **Arctic P12 Max** ou Noctua NF-A12x25, e airflow no **backplate** — os chips
  VRAM no verso **não têm sensor de temperatura**).
- **Display:** conexão **DisplayPort direta** sempre que possível. Adaptadores HDMI ativos/passivos
  podem causar tela preta no menu da BIOS.
- **Armazenamento:** M.2 NVMe/SATA (para instalar o sistema).
- **Pen drive:** ≥ 8 GB para o instalador; outro USB FAT32 (≤32 GB) para o flash da BIOS.
- **Opcional mas recomendado:** um **programador de hardware (WCH CH347)** como rede de segurança
  para recuperação de BIOS (unbrick). **Evite CH341A de PCB preto** (saída 5V — pode queimar o chip 3.3V).
- **Pasta térmica** nova (as placas ex-mineradoras costumam vir com pasta velha/ressacada).

---

## 3. BIOS: flash da versão modificada

> **Este é o passo mais crítico.** A BIOS modificada destrava **alocação dinâmica de VRAM** e
> menus avançados de chipset. Quase sempre vale a pena. Faça backup da BIOS original antes.

### 3.1 Qual arquivo usar (e como conferir o SHA256)

Sempre confira o hash com `sha256sum arquivo.rom` antes de gravar. Arquivos públicos com hashes
confirmados:

| Arquivo | Tipo | SHA256 |
|---|---|---|
| `BC250_3.00_CHIPSETMENU.ROM` | Mod P3.00 (VRAM + chipset, **recomendado**) | `48fbe5d366e6a56e2fdffdca848426216ba1f083610dab63db89d2f4e6c940b5` |
| `Robin5.00` | Stock P5.00 (16 MB) | `0d6f136cb120cf3b2de26d5c4d7f255604fdbf4b9442af5ba55419b95b89aa82` |
| `BC250_3.00.ROM` | Stock P3.00 (16 MB) | `07595ca3aecf8a4caa28a397b5298f3946a1b769f87b16f67adc369c3f69045c` |
| `BC250_2.00.bin` | Stock P2.00 (16 MB) | `ee6150dfed33bd05ea46063a352549416fdf3f45fa0e5edac2a68ef78d71083c` |

**Para 99% dos usuários: `BC250_3.00_CHIPSETMENU.ROM`.**

**Onde baixar:**
- Kit de ferramentas EFI (`AfuEfix64.efi` + `Flash.nsh`): https://github.com/kenavru/BC-250/raw/refs/heads/main/4U12G%20BIOS%20Update.zip
- BIOS modificada (P3.00 chipset menu): https://gitlab.com/TuxThePenguin0/bc250-bios/
- Repositórios espelhos citados na documentação (forgenam, tipitochen, csabakecskemeti, scrakcho, dannybastos).

> **Sobre o `P5.00_clv`:** é um mod P5.00 que destrava "tudo" (inclui experimental ReBAR),
> mas **não está publicado publicamente** (circula só no Discord, sem hash canônico) e é fácil
> de brickar. **Fique no P3.00** a menos que seja usuário avançado.

> **🔧 Tem uma base diferente (P4.00/P5.00) e quer customizar?** Mods públicas existem apenas para a
> base **P3.00** (chipset menu; e a `MeiMeiDXE-T-v2` com core unlock). Para montar uma **firmware
> customizada sua** (backup + flash com menu interativo), use o script
> [Forbidden-Darkness/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script](https://github.com/Forbidden-Darkness/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script)
> com os módulos DXE da comunidade (ex.: [BC250-DXE-SMU-Core-Unlock](https://github.com/RescueMei/BC250-DXE-SMU-Core-Unlock),
> [bc250-efi-core-unlock](https://github.com/Hexxeh/bc250-efi-core-unlock)) — e valide o resultado no
> [Discord](https://discord.gg/8eZfFWhczz) antes de gravar. Flash da mod P3.00 **sobre** qualquer base
> (P2–P5) é o caminho suportado e seguro.

### 3.2 Método 1 — Flash via USB (EFI Shell) — recomendado

1. Formate a pen drive em **FAT32**.
2. Extraia o conteúdo de `4U12G BIOS Update.zip` (pasta `BIOS EFI`) para a **raiz** do USB.
3. Salve o `Robin5.00` (stock P5.00) em local seguro — **não** use para flashear versão mod.
4. Coloque a BIOS mod na raiz do USB e **renomeie para `Robin5.00`** (sem extensão `.ROM`).
   A raiz do USB deve conter: `AfuEfix64.efi`, `Flash.nsh`, `amdvbflash.efi`, `Robin5.00`, pasta `EFI`.
5. **Desconecte todos os discos/SSDs** (sem drive de OS, a placa cai na EFI Shell automaticamente).
6. Insira o USB, ligue a placa. Ela deve entrar direto na **EFI Shell** (texto amarelo em fundo preto).
7. No prompt `Shell>`:
   - digite `blk0:` (com espaço depois dos dois pontos) e Enter;
   - digite `Flash.nsh` e Enter.
8. **NÃO toque no teclado nem desligue.** Se parecer travado, aguarde **15 minutos**.
9. Ao terminar, a placa reinicia. **Desligue e remova o USB imediatamente.**

### 3.3 O "CMOS Clear" crítico (não pule)

Após flashear: **remova a bateria CR2032 por ≥ 60 segundos** (opcional: aperte o botão de power
algumas vezes para descarregar); ou use o jumper de clear por 20 s. Só depois de limpar o CMOS os
ajustes de VRAM aplicam corretamente. Se as configurações não pegarem, a causa é CMOS não limpo.

### 3.4 Método 2 — Programador de hardware (recuperação/backup)

Necessário para **unbrick** (placa sem POST). Grave direto no chip SPI, usando **CH347** (recomendado)
ou Raspberry Pi Pico (serprog). **Chip alvo: `BIOS_A1` (16 MB, W25Q128 ou MX25L12835F).**
**NÃO toque no `SIO1_R` (512 KB, chip do fan control/SuperIO)** — gravar no chip errado mata o controle de ventoinha.

```bash
sudo apt install flashrom
sudo flashrom -p ch347_spi            # deve detectar W25Q128/MX25L128 (16MB). Se detectar MX25L4005 (512KB) => chip errado
sudo flashrom -p ch347_spi -r backup_stock.bin
sudo flashrom -p ch347_spi -r backup_verify.bin && diff backup_stock.bin backup_verify.bin
sudo flashrom -p ch347_spi -w BC250_3.00_CHIPSETMENU.ROM
```

### 3.5 Método 3 — Flashrom pelo Linux (avançado)

Grava o chip a partir do próprio sistema em execução. **Só para usuários avançados.** Faça backup
duplo, verifique pre-flight (lockdown `[none]`, Secure Boot desligado, `fwupd` parado, WP limpo),
grave **somente as regiões que diferem** (com layout file), verifique o hash antes de reiniciar, e
**pule se o boot block (últimos 512 KB) diferir** — nesse caso use o método USB.

```bash
sudo flashrom -p internal -r bios-backup-1.rom
sudo flashrom -p internal -r bios-backup-2.rom && cmp bios-backup-1.rom bios-backup-2.rom
# grave apenas as regiões diferentes, usando um layout.txt; confirme antes de reboot:
sudo flashrom -p internal -r readback.rom && sha256sum readback.rom new-bios.rom
```

---

### 3.6 Seu caso: stock P3.00 → mod P3.00 — kit pronto no pendrive

**Situação confirmada e preparada (2026-09-04):** sua placa está no **stock P3.00** e o alvo é o
**mod P3.00 CHIPSETMENU**. É o caminho de menor risco: mesma linhagem de firmware (boot block
idêntico entre o P3.00 stock e o mod; as diferenças ficam na região de NVRAM e num bloco
varstore/DXE), e existe imagem de recuperação verificada.

**Pendrive identificado:** SanDisk Cruzer Blade 16 GB → disco 3, **drive `I:`**, FAT32, rótulo "BIOS".

**Kit colocado na RAIZ do pendrive:**

| Item na raiz de `I:` | O que é |
|---|---|
| `Robin5.00` (16.777.216 bytes) | **É a BIOS mod P3.00 renomeada** — SHA256 `48fbe5d3…40b5` conferido ✔ |
| `Flash.nsh` | Conteúdo lido e confirmado: `AfuEfix64.efi Robin5.00 /p /b /n /k /x /rlc:e` + `reset` |
| `AfuEfix64.efi` | Utilitário AMI de flash em EFI |
| `amdvbflash.efi` | Utilitário auxiliar (não é usado pelo Flash.nsh) |
| `EFI\BOOT\` | Shell EFI do próprio kit (`Bootx64.efi`, `Shellx64.efi`, `Shell.efi`) — faz o pendrive bootar direto no shell |

> ⚠️ O `Robin5.00` **stock P5.00** que vinha dentro do zip **não foi deixado na raiz** de propósito
> (assim não existe risco de flashear o arquivo errado). Está arquivado como
> `bc250\bios\stock-P500-do-kit.ROM` — e o hash dele **bate** com o stock P5.00 oficial
> (`0d6f136c…aa82` ✔), o que valida o kit inteiro.

**Recuperação (baixada e verificada):** `bc250\bios\BC250_3.00.ROM` — o **stock P3.00** original,
SHA256 `07595ca3…045c` ✔. Se algo der errado: copie-a para a raiz renomeada como `Robin5.00` e
repita o método USB (ou use o programador CH347 da seção 3.4).

**Antes de flashear (opcional, recomendado):** no EFI Shell, rode `AfuEfix64.efi /?`; nas versões
de AFU que suportam dump, salve a imagem atual (formato comum: `AfuEfix64.efi P300-atual.rom /O`)
antes de aplicar o mod. Sem dump, a recuperação é a ROM stock verificada + programador.

**O boot físico é seu — não consigo executá-lo daqui** (exige desligar a máquina e interagir com o
EFI Shell; se a BC-250 for esta mesma máquina, o desligamento encerra esta sessão). Sequência:

1. Desligue a BC-250 **de verdade** (shutdown completo, não "Reiniciar").
2. Desconecte SSDs/drives (sem drive de OS, a placa cai direto no shell do pendrive) — ou
   selecione o pendrive no menu de boot.
3. Conecte o pendrive e ligue. O kit traz o shell embutido (`EFI\BOOT`): vai abrir o prompt
   amarelo `Shell>` automaticamente.
4. Digite `blk0:` (**com um espaço depois dos `:`**) → Enter; depois `Flash.nsh` → Enter.
   (Se `blk0:` não listar o pendrive, use `fs0:` e rode `Flash.nsh` de lá.)
5. **Não toque em nada e não desligue.** Se parecer travado, espere ≥ 15 min. O script dá `reset`
   sozinho ao terminar.
6. Quando reiniciar: **desligue imediatamente e remova o pendrive.**
7. **CMOS clear obrigatório:** bateria CR2032 fora por ≥ 60 s (aperte o botão power algumas vezes
   com a placa sem energia), recoloque.
8. Ligue, entre na BIOS (Del), confira CMOS limpo (relógio errado) e aplique a seção 4:
   GFX → Forces; UMA_SPECIFIED; **512MB**; Advanced → **IOMMU Disabled**; Boot → UEFI. F10 salva.
9. Se a BC-250 for esta máquina: reconecte o SSD e boote o Windows normalmente. A imagem seguirá
   sem aceleração de GPU — normal nesta placa (driver de GPU só no Linux).

---

## 4. Configuração da BIOS

Entre na BIOS apertando **Del** e configure:

| Ajuste | Onde | Valor recomendado |
|---|---|---|
| **UMA Frame Buffer Size** | Chipset → GFX Configuration → UMA | **512MB** (dinâmico) |
| **Integrated Graphics Controller** | Chipset → GFX Configuration | **Forces** |
| **UMA Mode** | Chipset → GFX Configuration | **UMA_SPECIFIED** |
| **IOMMU** | Advanced → CPU Configuration | **Disabled** (obrigatório — IOMMU está quebrado) |
| **Boot Mode** | Boot | **UEFI** |

**Opções de split de VRAM:**
- **512MB (Dinâmico)** — aloca automaticamente entre CPU/GPU. Melhor para uso geral.
- 10 GB RAM / 6 GB VRAM — bom para jogos AAA.
- 8 GB RAM / 8 GB VRAM — balanceado.
- 12 GB RAM / 4 GB VRAM — gaming leve, mais RAM de sistema.

> **Refrigeração do backplate:** os chips VRAM do verso não têm sensor. Garanta airflow sobre o
> backplate. Se aparecerem artefatos visuais, VRAM pode estar superaquecendo — adicione ventoinha.
> (Também dá para alterar o split de VRAM via Linux sem flashear, com `bc250_memcfg`.)

---

## 5. Instalação do CachyOS

> **Status atual:** CachyOS agora funciona **out-of-box** (late 2025). Os métodos complexos de
> ISO customizada NÃO são mais necessários.

### 5.1 Instalação padrão (recomendada)

1. Baixe ISO em https://cachyos.org/ (KDE ou GNOME).
2. Crie o USB bootável:
   ```bash
   sudo dd if=cachyos.iso of=/dev/sdX status=progress conv=sync && sync   # troque /dev/sdX pelo seu USB (lsblk)
   # ou use Ventoy / balenaEtcher / Rufus
   ```
3. Boote a BC-250 a partir do USB e rode o instalador:
   - **Particionamento:** auto ou manual (GPT + EFI).
   - **Desktop:** KDE Plasma ou GNOME.
   - **Bootloader:** GRUB (recomendado).
   - **Kernel:** padrão (deve ser compatível).
4. Verifique o kernel:
   ```bash
   uname -r    # esperado: 6.18.x LTS (recomendado) ou 6.17.11+
   ```
5. Reinicie.

**Kernels compatíveis / quebrados (importante):**
- ✅ 6.18.18 LTS (recomendado), 6.17.11+, 6.12–6.14 LTS, 6.19.x.
- ❌ 6.15.0–6.15.6 (falha de GPU/panic), 6.17.8–6.17.10 (problemas de driver, corrigido em 6.17.11+).

### 5.2 Se a ISO padrão não bootar

**Opção A — instalar em outro PC:** instale o CachyOS numa outra máquina no drive da BC-250,
instale kernel compatível (`sudo pacman -S linux-cachyos-lts linux-cachyos-lts-headers`), regenere o
GRUB e mova o drive de volta.

**Opção B — migração Arch → CachyOS (alternativa):**
```bash
wget https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo && sudo ./cachyos-repo.sh
# selecione x86-64-v3 (melhor compatibilidade com Zen 2) ou v4 (máx performance)
sudo pacman -S linux-cachyos-lts linux-cachyos-lts-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 6. Pós-instalação

### 6.1 GPU Governor (essencial — sem ele a GPU fica travada em 1500 MHz)

**Recomendado: `cyan-skillfish-governor-smu`** (via SMU, não precisa de patch de kernel).
```bash
yay -S cyan-skillfish-governor-smu
sudo systemctl enable --now cyan-skillfish-governor-smu.service
systemctl status cyan-skillfish-governor-smu
```
> Alternativa **TT** (`cyan-skillfish-governor-tt`, requer patch de kernel) e a legada **Oberon**.
> ⚠️ Verifique o **alvo do dispositivo** — o governor pode apontar para `card0` ou `card1`
> (`ls /sys/class/drm/` para descobrir o correto). Verifique com:
> ```bash
> cat /sys/class/drm/card0/device/pp_dpm_sclk     # deve mostrar várias frequências, com * na ativa
> ```
> Se ficar preso em 1500 MHz, é sinal de governor não ativo.

### 6.2 Sensores (temperatura, tensão, ventoinha)

```bash
sudo pacman -S lm_sensors
# monitoramento read-only (nct6683):
echo 'nct6683' | sudo tee /etc/modules-load.d/nct6683.conf
echo 'options nct6683 force=true' | sudo tee /etc/modprobe.d/sensors.conf
sudo mkinitcpio -P && sudo reboot
sensors    # deve mostrar nct6686-isa-0a20, temp GPU, RPM
```
> Para **controle de ventilador PWM** use o módulo `nct6687` (veja a doc de sensors) ou o
> **CoolerControl** (`yay -S coolercontrol`).

### 6.3 Parâmetros de kernel

```bash
sudo nano /etc/default/grub
# para kernels 6.10+, amdgpu.sg_display=0 NÃO é necessário
GRUB_CMDLINE_LINUX_DEFAULT="quiet mitigations=off"   # desativa mitigações de segurança (ganho de perf)
sudo grub-mkconfig -o /boot/grub/grub.cfg && sudo reboot
```

### 6.4 Ferramentas de gaming

```bash
sudo pacman -S steam mangohud goverlay gamemode gamescope nvtop htop fastfetch
sudo pacman -S protonup-qt
```

### 6.5 Verificação final

```bash
uname -r                                               # kernel compatível
glxinfo | grep "OpenGL version"                        # Mesa 25.1+
vulkaninfo | grep deviceName                           # AMD Radeon Graphics (RADV GFX1013)
systemctl status cyan-skillfish-governor-smu           # active (running)
cat /sys/class/drm/card0/device/pp_dpm_sclk            # várias frequências
```

---

## 7. ACPI: C-states e P-states (o "cache de ACPI")

> Este é exatamente o ponto que você chamou de "informação de cache ACPI". A placa vem com uma
> **tabela ACPI defeituosa**: as CPUs nunca entram em C-states (não "dormem" no idle) e não têm
> P-states (escalonamento de frequência 800–3200 MHz). O **fix ACPI** resolve isso.

**O que o fix entrega:**
- **SSDT-CST (C-states):** C1/C2/C3 — as CPUs entram em sleep no idle (economia de energia).
- **SSDT-PST (P-states):** escalonamento de 800 MHz a 3200 MHz pelos governors padrão do Linux
  (`schedutil`, `powersave`, `performance`).

### 7.1 Aplicação no CachyOS (8 núcleos — recomendado)

O fix da comunidade é para 6 núcleos (parando no thread `C00B`, 12 threads). Se você destravar os
**8 núcleos**, precisa das tabelas **8-core** (vão até `C00F`, cobre 16 threads), senão os CPUs
12–15 ficam **sem C-states** e queimam energia no idle.

```bash
sudo -i
mkdir -p /etc/initcpio/acpi_override/
cd /etc/initcpio/acpi_override/
wget -nc https://github.com/mendesrr/bc250-acpi-fix-updated-8c/raw/refs/heads/main/SSDT-CST.aml \
          https://github.com/mendesrr/bc250-acpi-fix-updated-8c/raw/refs/heads/main/SSDT-PST.aml
sed -i '/^HOOKS=/ { /acpi_override/q; s/microcode/& acpi_override/; q }' /etc/mkinitcpio.conf
mkinitcpio -P
systemctl reboot
```

> **Do 6-core (bc250-collective/bc250-acpi-fix)** para outras distros: monte o cpio em
> `kernel/firmware/acpi/`, copie para `/boot/acpi_override.cpio`, e no GRUB adicione
> `GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override.cpio"` (Fedora) ou `"/../..."` (conforme a doc).

### 7.2 Verificar

```bash
cpupower idle-info        # todos os CPUs, inclusive 12–15, devem ter C-states
cpupower frequency-info   # deve mostrar faixa 800–3200 MHz
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor   # ex: schedutil
```

**Setar governor de CPU recomendado** (`schedutil` ou `performance`):
```bash
echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# performance permanente:
sudo cpupower frequency-set -g performance
sudo systemctl enable --now cpupower.service
```

> **Nota de atualização de kernel:** ao trocar de kernel, recrie o initrd (`mkinitcpio -P`) — o
> override ACPI precisa ser regenerado.

---

## 8. Otimização para games

O CachyOS já traz várias otimizações por padrão. Complementos:

- **BORE scheduler:** já ativo no kernel do CachyOS (melhora frame time e latência). Nada a fazer.
- **Pacotes otimizados x86-64-v3/v4:** dão ~5–10% de FPS em alguns jogos. Escolha **v3** para
  compatibilidade (Zen 2 suporta v3) ou **v4** para máximo (verifique se seu CPU tem AVX-512).
- **Proton:** ative em Steam → Settings → Compatibility → "Enable Proton for all titles".
  Instale **Proton GE** via `protonup-qt`.
- **Launch options no Steam** (para alguns jogos com glitches gráficos):
  ```
  RADV_DEBUG=nohiz %command%
  ```
- **MangoHud** (overlay em jogo): use `mangohud %command%`. Edite `~/.config/MangoHud/MangoHud.toml`.
  (No BC-250, o `cyan-skillfish-governor-smu` tem um fix de métricas para o bug do "655%" do MangoHud.)
- **gamescope** para escalonamento/limite de FPS.
- **gamemode** (já ativado pelo `libgamemode` quando o jogo usa).

**Perfil de referência da comunidade (BOA relação perf/temperatura):** GPU ~1600 MHz, CPU ~3500 MHz
— muito mais silencioso e fresco, com desempenho próximo do máximo. (Fonte: r/BC250Gaming.)

---

## 9. Unlock de 8 núcleos de CPU

A BC-250 traz 6 de 8 núcleos Zen 2. Os outros 2 **não estão fundidos** — são mascarados por um
registro SMU gravável. Um único registro controla a disponibilidade:

| Registro | O que faz | Stock | Destravado |
|---|---|---|---|
| `SMN 0x0115A870` | máscara de núcleos por bit | `0x77` (núcleos 3 e 7 mascarados) | `0xFF` (8 núcleos) |

> **⚠️ Pare o governor antes de mexer (inclui leitura).** `cyan-skillfish-governor-smu` usa o mesmo
> par index/data `0xB8`/`0xBC` em `00:00.0`. Pare o serviço, faça a operação, religue.
> **⚠️ Reset quente mantém, reset frio perde:** `reboot` preserva a máscara; desligar na tomada/
> PSU reverte para 6 núcleos (isso é uma "rede de segurança").

**Método 1 — via Linux (sem flash, reversível):**
```bash
git clone https://github.com/GabriWar/bc250-core-cu-unlock && cd bc250-core-cu-unlock
sudo ./bc250-8core-unlock.sh status     # mostra a máscara atual
sudo ./bc250-8core-unlock.sh apply      # destrava agora; depois: sudo reboot
sudo ./bc250-8core-unlock.sh install    # persiste (unit systemd) — re-aplica após boot frio
```
> Rode `sudo ./bc250-8core-unlock.sh apply` e **escolha você quando reiniciar** — não deixe
> nenhum script reiniciar sozinho (versões antigas bootloopavam).
> Requer `pciutils` e root.

**Método 2 — via BIOS (permanente):** o mod `MeiMeiDXE-T-v2` contém o driver `Bc250CoreUnlockDxe`,
que faz o mesmo antes do OS, em todo boot. Feito sobre **P3.00**; se você está em P5.00 ou outro mod,
isso é um **downgrade** (perde o que o mod atual destrava). Tenha backup e programador antes.

**Depois de destravar, você DEVE:**
1. **Atualizar as tabelas ACPI** para 8 núcleos (seção 7.1) — senão CPUs 12–15 ficam sem C-states.
2. **Revalidar o overclock/undervolt** (as curvas antigas não valem — 2 núcleos a mais mudam
   elétrica/térmica do SoC).

**Verificar:**
```bash
lscpu | grep -E 'Core\(s\) per socket|^CPU\(s\)'   # Core(s) per socket: 8 / CPU(s): 16
sudo ./bc250-8core-unlock.sh status                # SMN 0x0115A870 = 0xFF
```

**Performance:** +26,9% no 7-zip (8 núcleos em clock stock vs. 6 núcleos com OC a 3800 MHz), no teste
da comunidade. Ganho maior em cargas multi-thread; cargas limitadas por memória continuam limitadas
pelo FCLK de 450 MHz.

---

## 10. Unlock das 40 CUs de GPU

A placa traz 24 de 40 Compute Units. As 16 CUs restantes **não estão danificadas** — estão apagadas
por firmware. Dois registros precisam ser alterados juntos:

| Registro | O que faz | Stock | Destravado |
|---|---|---|---|
| `CC_GC_SHADER_ARRAY_CONFIG` | informa ao driver quantas CUs existem | `0xfff80000` (24 CU) | `0xffe00000` (40 CU) |
| `SPI_PG_ENABLE_STATIC_WGP_MASK` | diz ao SPI para onde despachar waves | `0x07` (WGP 0-2) | `0x1F` (WGP 0-4) |

**Ganho:** ~**1.61x** em compute (llama-bench 230→372 tok/s a 1500 MHz). Em gráficos (games) o ganho é
bem menor (+4,4% em glmark2) porque 3D é *fill-rate bound*, não *CU-bound*. **Isto é um unlock de
compute, não de gaming.**

> **⚠️ Nem toda placa destrava 40 CUs de forma limpa.** Padrão de harvest **contíguo** (CU 0-5 ativas,
> 6-9 apagadas, igual nos 4 shader arrays) tende a destravar 40 e passar nos testes. Padrão
> **espalhado** pode ter CUs **defeituosas** que passam na enumeração mas falham em carga.
> Rode `./scripts/cu_map.sh` para ver o padrão da SUA placa antes.
>
> **⚠️ Overclock sustentado nas 40 CUs em 2 GHz vai throttle** no dissipador de fábrica. Para carga
> sustentada, **cap em 1500 MHz** (config do governor) ou melhore o cooling. Planos de PSU/cooling
> para o limite superior (Cyberpunk stock 24 CU já puxou 235 W; Furmark OC 320 W).
>
> **⚠️ Secure Boot desligado** (ou assine o módulo). **Cada atualização de kernel reverte** (módulo
> out-of-tree) — reconstrua ou fixe o kernel.

### Instalação — método do script de build (recomendado)

```bash
git clone https://github.com/duggasco/bc250-40cu-unlock.git && cd bc250-40cu-unlock
# escolha o script da sua distro:
sudo ./scripts/bc250-enable-40cu-arch.sh build      # Arch/CachyOS
sudo ./scripts/bc250-enable-40cu-arch.sh enable     # grava modprobe e reinicia
```
Requisitos: `gcc make zstd` + headers do kernel (`linux-headers` no Arch).

**Para CachyOS/Arch com PKGBUILD:** aplique `patch/bc250-40cu-amdgpu.patch` ao PKGBUILD do kernel
(`linux-cachyos`), reconstrua e adicione a config do modprobe. Bundle no `bc250-enable-40cu-arch.sh`.

**Alternativa runtime (sem rebuild do módulo):** use o **bc250-cu-live-manager** (via `umr`), que
escreve os registros userspace após o driver subir, com TUI e persistência em boot:
```bash
curl -L -o bc250-cu-live-manager.sh https://raw.githubusercontent.com/WinnieLV/bc250-cu-live-manager/refs/heads/main/bc250-cu-live-manager.sh
chmod +x bc250-cu-live-manager.sh && sudo ./bc250-cu-live-manager.sh
```

**Verificar:**
```bash
cat /sys/module/amdgpu/parameters/bc250_cc_write_mode   # 3
sudo dmesg | grep active_cu_number                      # active_cu_number 40
RADV_DEBUG=info vulkaninfo --summary 2>&1 | grep num_cu # num_cu = 40
```
Se `active_cu_number` for 24, o módulo patchado não carregou (confira o modprobe.conf, se não foi
sobrescrito por atualização, e Secure Boot).

**Reverter:**
```bash
sudo ./scripts/bc250-enable-40cu-arch.sh disable    # remove config do modprobe
sudo ./scripts/bc250-enable-40cu-arch.sh restore    # restaura amdgpu original (backup .bc250-backup-*)
```

---

## 11. Overclock

> **Regra de ouro:** o **thermal é o limite real** (não o silício). 2000 MHz @ 1000 mV é o ponto de
> partida seguro para todas as placas. Teste 30+ min por degrau. A 2150–2200 MHz use 1000 mV
> (muitas placas nem precisam de mais).

### 11.1 Curva do GPU governor (SMU) — arquivo `/etc/cyan-skillfish-governor-smu/config.toml`

```toml
[timing.intervals]
sample = 500
adjust = 200_000

[gpu-usage]
fix-metrics = true
method = "busy-flag"
flush-every = 10

[gpu]
set-method = "smu"

[dbus]
enabled = true

[timing.ramp-rates]
normal = 1
burst = 50

[timing]
burst-samples = 60
down-events = 5

[frequency-thresholds]
adjust = 10

[load-target]
upper = 0.80
lower = 0.65

[temperature]
throttling = 85
throttling_recovery = 75

[[safe-points]]
frequency = 1000
voltage = 800

[[safe-points]]
frequency = 1500
voltage = 900

[[safe-points]]
frequency = 2000
voltage = 1000

[[safe-points]]
frequency = 2150
voltage = 1000

[[safe-points]]
frequency = 2200
voltage = 1000
```

Reinicie após mudar: `sudo systemctl restart cyan-skillfish-governor-smu`.

> ⚠️ **Nunca abaixo de 700 mV** — trava a GPU em 1500 MHz e anula o governor.

**Limites conhecidos (dependem do cooling):** 2000 MHz @ 1000 mV (seguro), 2100–2175 MHz @
1025–1050 mV (testar), 2230 MHz @ 1060 mV (conservador em ar), 2300 MHz @ 1075 mV (bom ar com P12 Max),
2400 MHz @ 1125 mV (só líquido).

**Testar estabilidade manualmente:**
```bash
sudo systemctl stop cyan-skillfish-governor-smu
echo "vc 0 2100 1025" | sudo tee /sys/class/drm/card0/device/pp_od_clk_voltage
echo "c" | sudo tee /sys/class/drm/card0/device/pp_od_clk_voltage
# rode benchmark/jogo por 30+ min, monitore sensors
```

### 11.2 Overclock de CPU (bc250_smu_oc)

```bash
git clone https://github.com/bc250-collective/bc250_smu_oc.git && cd bc250_smu_oc
pip install --user .
# testar (auto-tune de tensão):
sudo bc250-detect -f 3700 -v 1231
# testar com --keep para manter o OC
sudo bc250-detect -f 3900 -v 1280 -k
# permanente:
sudo bc250-detect -f 3900 -v 1280 -k -c /etc/bc250-overclock.conf
sudo bc250-apply -a -i /etc/bc250-overclock.conf
sudo systemctl enable bc250-smu-oc
```
Resultados verificados (Fedora 43, kernel 6.19.8): 3700 MHz +4,4%, 3800 MHz +7,1%, 3900 MHz +9,0%
(4000 MHz throttles). Combinado com P-states + `schedutil`: **800 MHz idle → 3900 MHz load**.

> Depois do unlock 8-core, **revalide** o OC (seção 9). E note: um detect upstream pode gravar um
> `overclock.conf` no diretório atual e resetar seu undervolt — use com cuidado.

---

## 12. Avisos de segurança e riscos

- **Hardware ex-minerador, sem garantia.** Venda "as-is".
- **Flash de BIOS tem risco de brick.** Faça backup; tenha programador (CH347) como rede de segurança.
- **Grave no chip certo** (`BIOS_A1` 16 MB), nunca no `SIO1_R` (512 KB / SuperIO).
- **Polaridade do conector 8-pin:** conferir antes de ligar. Inversão queima a placa.
- **Nunca use Smokeless_UMAF** (dano permanente).
- **Unlock de CUs/núcleos:** aumentam calor e consumo. **Nem toda placa é 100% saudável nas regiões
  destravadas** — teste com os scripts de health (40 CU: `bc250-cu-health-test.sh`; 8 core: `test-cores.sh`).
- **Cap de temperaturas:** GPU < 85–90 °C sob carga; 95–100 °C é throttle.
- **Só Linux para gráficos.** Windows sem driver de GPU.
- **Kernels quebrados:** evite 6.15.0–6.15.6 e 6.17.8–6.17.10.
- **Secure Boot off** para os unlocks de módulo out-of-tree.
- Reavalie seu OC/curva depois de qualquer unlock de núcleos/CUs.

---

## 13. Troubleshooting

**GPU não detectada / vulkaninfo mostra llvmpipe:**
1. `sudo dnf list mesa-*` / `pacman -Q mesa` — precisa Mesa 25.1+.
2. `uname -r` — kernel compatível (não 6.15.0–6.15.6 nem 6.17.8–6.17.10).
3. Remova `nomodeset` do GRUB/kargs (ver abaixo).

**Remover `nomodeset` (obrigatório após drivers):**
- GRUB: edite `/etc/default/grub`, troque `quiet nomodeset` → `quiet`, `grub2-mkconfig -o /boot/grub2/grub.cfg`, reboot.
- Bazzite/Atomic: `rpm-ostree kargs --delete-if-present="nomodeset"` e `systemctl reboot`.

**Baixo FPS / GPU travada em 1500 MHz:**
```bash
systemctl status cyan-skillfish-governor-smu      # active (running)
cat /sys/class/drm/card0/device/pp_dpm_sclk       # deve mostrar * se movendo sob carga
sudo journalctl -u cyan-skillfish-governor-smu --no-pager -n 20
```

**Governor não sobe no boot (CachyOS/Arch):** conhecido. Rode um jogo/benchmark uma vez para ativar.

**Temperatura alta:**
1. Verifique ventoinhas em full speed.
2. Endireite as aletas do dissipador (costumam vir amassadas).
3. Troque a pasta térmica.
4. Use ventoinha de alta pressão estática (Arctic P12 Max).

**Tela preta na instalação:** boote com `nomodeset` (modo "Basic Graphics").

**Artefatos visuais em jogos:** `RADV_DEBUG=nohiz %command%` (launch options do Steam); reduza a
frequência da GPU; verifique VRAM/temperatura do backplate.

**Após flash, ajustes não persistem:** limpe o CMOS de novo (bateria 60 s).

**Crash com governor:** quase sempre é térmica. Se GPU ≥ 95 °C, é cooling, não tensão. Diminua a
frequência máxima da curva; só depois considere +25 mV no topo.

**Boot block difere (flashrom interno):** pare e use o método USB.

---

## 14. Scripts e ferramentas baixados

Repositórios catalogados, correlacionados e clonados localmente durante a preparação deste material — use os links para acessar o código-fonte oficial:

| Repositório | Para quê | Path local |
|---|---|---|
| `elektricM/amd-bc250-docs` | Documentação oficial | `repos/amd-bc250-docs` |
| `redbeard1083/bc250-toolkit` | Setup automatizado no CachyOS | `repos/bc250-toolkit` |
| `bc250-collective/bc250-acpi-fix` | Fix ACPI 6-core (C/P-states) | `repos/bc250-acpi-fix` |
| `mendesrr/bc250-acpi-fix-updated-8c` | **Fix ACPI 8-core** (recomendado p/ 8 núcleos) | `repos/bc250-acpi-fix-updated-8c` |
| `GabriWar/bc250-core-cu-unlock` | Unlock de 8 núcleos (Linux) + teste | `repos/bc250-core-cu-unlock` |
| `rw-r-r-0644/bc250-core-unlock` | Unlock de núcleos (alternativo) | `repos/bc250-core-unlock` |
| `duggasco/bc250-40cu-unlock` | Unlock 40 CUs + scripts de health | `repos/bc250-40cu-unlock` |
| `bc250-collective/bc250_smu_oc` | Overclock/undervolt de CPU | `repos/bc250_smu_oc` |
| `MastaG/linux-cachyos-bc250` | Kernel CachyOS com patches BC-250 | `repos/linux-cachyos-bc250` |
| `Forbidden-Darkness/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script` | Script de menu UEFI v2.2 (flash/backup) | `repos/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script` |
| **Kit de BIOS baixado** | BIOS mod P3.00 (hash ✔) + tools EFI + **stock P3.00 de recuperação** (hash ✔) | `bios/` |

**Scripts avulsos (prontos para uso) e tabelas ACPI** — você encontra dentro dos repositórios acima:
- `bc250-toolkit.sh` (CachyOS): instala governor, swap/zram, OC, unlock de CU e núcleos, fix ACPI e kernel.
  Rode: `curl -sSLO https://raw.githubusercontent.com/redbeard1083/bc250-toolkit/main/bc250-toolkit.sh && chmod +x bc250-toolkit.sh && ./bc250-toolkit.sh`
  (requer **GRUB** nesta versão; leia o README).
- `SSDT-CST.aml` / `SSDT-PST.aml` (6-core em `repos/bc250-acpi-fix`; **8-core em `repos/bc250-acpi-fix-updated-8c`**).
- `bc250-8core-unlock.sh` / `test-cores.sh` (em `repos/bc250-core-cu-unlock`).
- `bc250-enable-40cu-arch.sh`, `cu_map.sh`, `bc250-cu-health-test.sh`, `bc250-cu-mask.sh` (em `repos/bc250-40cu-unlock`).
- `bc250_detect.py` / `bc250_apply.py` (em `repos/bc250_smu_oc`).

> **BIOS (.rom) — já baixada neste diretório:** os binários estão em `bios/` e o hash foi conferido
> (seção 3.1).
> - `bios/BC250_3.00_CHIPSETMENU.ROM` (16 MB) — **BIOS modificada P3.00 recomendada**.
>   SHA256 verificado: `48fbe5d366e6a56e2fdffdca848426216ba1f083610dab63db89d2f4e6c940b5` ✔
> - `bios/4U12G BIOS Update.zip` — kit de ferramentas EFI (`AfuEfix64.efi` + `Flash.nsh`).
> - `bios/BC250_3.00.ROM` — **stock P3.00 (imagem de recuperação)**, SHA256 `07595ca3…045c` verificado ✔
> - `bios/stock-P500-do-kit.ROM` — stock P5.00 extraído do kit (hash confere com o oficial ✔)
>
> ✅ **A raiz do pendrive (`I:`) já está preparada para o flash** — veja a seção 3.6.
>
> ⚠️ *Por segurança, rode `sha256sum bios/BC250_3.00_CHIPSETMENU.ROM` (ou `Get-FileHash`) e compare
> com o hash acima antes de flashear.*

---

## 15. Fontes

**Documentação oficial (principal):**
- https://elektricM.github.io/amd-bc250-docs/ (repositório: `elektricM/amd-bc250-docs`)
- https://github.com/mothenjoyer69/bc250-documentation
- Repositórios clonados listados na seção 14.

**GitHub (código/scripts/projetos):**
- `duggasco/bc250-40cu-unlock`, `rw-r-r-0644/bc250-core-unlock`, `GabriWar/bc250-core-cu-unlock`,
  `bc250-collective/bc250-acpi-fix`, `mendesrr/bc250-acpi-fix-updated-8c`, `bc250-collective/bc250_smu_oc`,
  `redbeard1083/bc250-toolkit`, `MastaG/linux-cachyos-bc250`, `filippor/cyan-skillfish-governor`,
  `WinnieLV/bc250-cu-live-manager`, `Forbidden-Darkness/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script`,
  `fanoush/bc250_memcfg`, `Hexxeh/bc250-efi-core-unlock`, `ZEROAESQUERDA/PS5GPU-BC250`,
  `NexGen-3D-Printing/SteamMachine`, `akandr/bc250`, `movacx/bc250-control-center`.

**Reddit:**
- r/BC250Gaming — https://www.reddit.com/r/BC250Gaming/
  - "My BC250 Journey: From Bazzite to CachyOS – Better..." (1600 MHz GPU / 3500 MHz CPU: melhor equilíbrio).
  - "Is the ACPI Fix still required if running Bazzite?"
  - "The 40 CU unlock and BC250 original purpose" — "quase dobre as CUs com o unlock".
  - "CachyOS support" — "instale CachyOS e rode o script" (bc250-toolkit).
- r/cachyos (como instalar jogos no CachyOS).

**Fóruns especializados:**
- Linus Tech Tips — "AMD BC 250 part two - the easy one": https://linustechtips.com/topic/1632041-amd-bc-250-part-two-the-easy-one/
- Tom's Hardware — benchmarking do BC-250 e o hack das 40 CUs:
  https://www.tomshardware.com/pc-components/cpus/benchmarking-amds-bc-250-offering-steam-machine-like-performance-at-half-the-price-unlocking-40-cus-eight-zen-2-cores-on-the-repurposed-ps5-apu
- discuss.cachyos.org (otimização geral para gaming).

**YouTube:**
- Playlist "The AMD BC-250": https://www.youtube.com/playlist?list=PLSFIXw492NX_cWbcPWsnh50EE9Z6_Lofq

**Comunidade:** Discord da BC-250 (link no GitHub `elektricM/amd-bc250-docs`), ~9.700 mensagens
técnicas de 3.500+ membros.

---

*Este guia foi compilado a partir das fontes acima, correlacionando GitHub, Reddit, fóruns e YouTube.
O conteúdo reflete o estado da comunidade em 2026-09-04. Verifique sempre as fontes originais e a doc
oficial, que é atualizada com frequência, antes de executar qualquer passo destrutivo.*
