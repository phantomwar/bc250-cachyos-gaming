# ❓ FAQ — Perguntas Frequentes sobre a BC-250

> Respostas curtas e diretas, organizadas por nível. O detalhamento completo de cada tema está no
> **[guia completo](docs/GUIA_BC250_CACHYOS_GAMING.md)** — as seções estão linkadas em cada resposta.

---

## 🐣 Primeiros passos

### 1. Posso usar Windows?

**Não para gráficos.** Não existe driver de GPU para Windows nesta placa — sem aceleração, sem jogos, sem compute. Use Linux: **CachyOS** (performance máxima, foco deste guia), **Bazzite** (experiência "console") ou Fedora. O Windows até bootaria, mas a tela roda sem aceleração e o hardware de GPU fica inutilizável.
→ *Guia, seção 1.*

### 2. Preciso flashear a BIOS logo de cara?

**Recomendado fortemente.** A BIOS modificada (P3.00 chipset menu) destrava a **alocação dinâmica de VRAM** e os menus de chipset — sem ela a experiência é bem pior. Existe uma alternativa para *só* mudar o split de VRAM sem flash (`bc250_memcfg`), mas os menus desbloqueados valem o flash. → *Guia, seções 3 e 3.6.*

### 3. Bazzite ou CachyOS?

| | **CachyOS** | **Bazzite** |
|---|---|---|
| Perfil | Arch otimizada p/ performance | "Console" — modo Steam |
| Scheduler | BORE (frame time melhor) | CFS padrão |
| Kernel BC-250 patch | Manual (ou governor SMU, sem patch) | Já vem com patch de frequência |
| Exigência | Familiaridade com Arch/terminal | Quase plug-and-play |

Este guia cobre o **CachyOS**. Se você quer experiência de console sem mexer em terminal, vá de Bazzite e procure o toolkit da NexGen-3D. → *Guia, seção 5.*

### 4. Preciso ser expert em Linux?

Não precisa ser *expert*, mas convém ter **conforto com terminal**. Os passos do guia são copiar-e-colar, e o `setup-bc250-cachyos.sh` automatiza a pós-instalação. O flash da BIOS é a única parte "fora do sistema operacional" — e é guiada comando a comando.

### 5. Quanto custa o setup total?

A placa é vendida barata no mercado de usados (foi feita às centenas para mineração). Além dela você precisa de: **PSU com 8-pin PCIe (250 W+ no 12 V)**, **cooler/ventoinhas decentes** (Arctic P12 Max ou similar), SSD M.2 e pendrive. O resto (cabo DP,Case) é o que você já tem. Consulte os grupos da comunidade para preços atuais.

---

## 🎮 Jogos e performance

### 6. Quantos FPS eu vou ter?

Referências da comunidade (1080p): **Cyberpunk 2077** 60–90 FPS (alto + FSR), **DMC 5** 100+ FPS, **Control ~40 FPS com RT**, **Forza Horizon** fluido. A placa se aproxima de uma **RX 6600 / GTX 1660 Ti**. Com o governor bem ajustado, o ganho está na **consistência de frame time** tanto quanto no FPS bruto. → *Guia, seção 1 e 8.*

### 7. Dá para jogar em 1440p ou 4K?

**1440p:** em jogos leves ou com FSR, sim — mas espere sacrificar qualidade. **4K:** não realista; a placa é otimizada para **1080p**. Lembre que a GPU compartilha os 16 GB GDDR6 com a CPU.

### 8. Ray tracing funciona?

Funciona, mas é **limitado** — a RDNA2 da BC-250 tem RT por hardware, e jogos como Control rodam ~40 FPS com RT em 1080p. Para RT, mantenha as configurações baixas e use FSR.

### 9. A GPU fica travada em 1500 MHz. É isso mesmo?

**Sem o governor, sim** — é o lock de fábrica. Instale o **`cyan-skillfish-governor-smu`** e a GPU passa a escalar de ~1000 MHz (idle) até 2000–2230 MHz (carga), com tensão dinâmica. Se instalou e continua travada: verifique o serviço, o arquivo de config e se o governor está mirando o `card0`/`card1` correto. → *Guia, seções 6.1 e 13.*

### 10. Serve para IA/LLMs?

**Surpreendentemente sim.** Com os 40 CUs destravados, a placa roda inferência Vulkan muito bem (~60 tok/s em modelos 8B; 1.61× de ganho de compute com o unlock). O repositório [akandr/bc250](https://github.com/akandr/bc250) documenta LLM, Stable Diffusion e ROCm-vs-Vulkan em profundidade. Para IA, o unlock das 40 CUs vale muito mais que para jogos. → *Guia, seção 10.*

---

## 🔧 BIOS e hardware

### 11. Como atualizo a BIOS da minha placa stock P3.00?

O caminho validado: pendrive FAT32 com o **kit EFI + a ROM mod P3.00 renomeada para `Robin5.00`**, boot no EFI Shell da própria placa, `blk0:` + `Flash.nsh`, **CMOS clear depois**. O script [`scripts/make_flash_usb.ps1`](scripts/make_flash_usb.ps1) monta esse pendrive com **verificação de hash** no Windows. → *Guia, seções 3.2 e 3.6.*

### 12. O que é o "fix ACPI" e por que preciso dele?

A BIOS de fábrica entrega **tabelas ACPI quebradas**: sem **C-states** (as CPUs não "dormem" no idle — consumo alto) e sem **P-states** (sem escalonamento de frequência 800–3200 MHz). O fix carrega SSDTs corrigidos (`SSDT-CST`/`SSDT-PST`) via initrd. Se você destravar os **8 núcleos**, use obrigatoriamente a versão **8-core** das tabelas, senão os CPUs 12–15 ficam sem C-states. → *Guia, seção 7.*

### 13. É seguro destravar os 8 núcleos? E as 40 CUs?

**Mecanicamente, sim — e é reversível.** O unlock de núcleos é um registro SMU que volta ao padrão ao cortar a energia (uma "rede de segurança" natural); o de CUs é um patch do driver. O risco real é **térmico/energético** e o "silicon lottery": nem toda placa tem as CUs extras saudáveis. Rode `test-cores.sh` (núcleos) e `cu_map.sh` + health test (CUs) antes de confiar. Depois de qualquer unlock, **revalide seu overclock**. → *Guia, seções 9 e 10.*

### 14. Brick na BIOS — como recupero?

Em ordem: (1) **CMOS clear** (bateria 60 s) resolve a maioria; (2) re-flash via outro pendrive/kit; (3) **programador de hardware** (CH347 ou Pi Pico com serprog) gravando direto no chip `BIOS_A1` de 16 MB — **nunca** no `SIO1_R` de 512 KB (é o chip do fan control). A imagem de recuperação é a **stock P3.00** (hash público). → *Guia, seções 3.4 e 3.5.*

### 15. Preciso trocar a pasta térmica / melhorar o cooler?

**Sim para a pasta** (placas de mineração passaram anos a 80 °C+). **Recomendado para o cooler**: ventoinha de alta pressão estática (Arctic P12 Max, Noctua) e **airflow no backplate** — os chips de VRAM do verso **não têm sensor de temperatura**. Se você viu artefatos visuais, é VRAM esquentando. → *Guia, seção 2 e 13.*

### 16. Que fonte eu preciso?

**250 W+ no trilho 12 V** para uso normal; mais folga (300 W+) se for fazer overclock ou destravar CUs. Jogos puxam 220–250 W; FurMark com OC já passou de 320 W. E **conferem a polaridade do 8-pin antes de ligar** — invertido queima a placa. → *Guia, seção 2.*

### 17. Tem WiFi/Bluetooth?

**Não embutido.** Use adaptadores USB (funcionam normalmente no Linux) ou um dongle barato.

### 18. Como funciona o áudio?

Via **DisplayPort** — adaptadores passivos DP→HDMI costumam funcionar; ativos podem falhar. O áudio analógico da placa é limitado; para home theater existe um projeto comunitário de **5.1 AC3 over HDMI** (`rpf16rj/bc250-steamos-real-toolkit`). → *Guia, seção 13.*

---

## ⚡ Avançado

### 19. Quais versões de kernel devo usar (ou evitar)?

**Use:** 6.18 LTS (recomendado), 6.17.11+, 6.12–6.14 LTS, 6.19.x.
**Evite:** **6.15.0–6.15.6** (falhas de init da GPU/panic) e **6.17.8–6.17.10** (problemas de driver, corrigidos no 6.17.11+). Instalou um quebrado? Volte para `linux-cachyos-lts`. → *Guia, seção 5.1.*

### 20. Quanto a placa consome?

Idle sem otimização: **50–80 W**; com o governor + ACPI fix bem ajustados, cai para **65–85 W**. Em jogos: 220–250 W. Com 40 CUs destravadas e 2 GHz, cargas sustentadas podem passar de 220–230 W — por isso o cap em 1500 MHz é recomendado para uso contínuo. → *Guia, seções 6 e 10.*

### 21. Como faço overclock sem "bronzeá" a placa?

Comece em **2000 MHz @ 1000 mV** (seguro para todas as placas), teste **30+ minutos por degrau**, e respeite o teto térmico: **GPU < 85 °C** sob carga. Acima de 2150–2200 MHz o retorno cai e o calor sobe — a maioria se sai melhor em 2000–2100 MHz estável do que perseguindo 2230. **Nunca abaixo de 700 mV** (trava a GPU em 1500 MHz). → *Guia, seções 11 e 12.*

### 22. FSR 4 funciona?

Há um projeto comunitário explorando FSR 4 na placa ([dmorazasanchez/bc250-fsr4](https://github.com/dmorazasanchez/bc250-fsr4)) — é território experimental. FSR via Proton/gamescope funciona normalmente.

### 23. Onde tiro dúvidas complexas?

- **Discord da BC-250** (link no repositório `elektricM/amd-bc250-docs`) — 3.500+ membros, ~10 mil mensagens técnicas;
- **[r/BC250Gaming](https://www.reddit.com/r/BC250Gaming/)** no Reddit;
- **Documentação viva:** [elektricM.github.io/amd-bc250-docs](https://elektricM.github.io/amd-bc250-docs/).

---

<div align="center">

**Não achou sua dúvida?** [Abra uma issue](../../issues) — ela pode virar o próximo item deste FAQ.

</div>
