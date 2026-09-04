# 🌬️ Guia de Refrigeração e Cases 3D para a BC-250

> **O que é isto:** guia dedicado à **refrigeração recomendada** pela comunidade (ventoinhas, pastas,
> VRAM do backplate, controle de fan) e ao **catálogo de cases impressos em 3D** — incluindo os
> projetos para **gabinete/PSU ATX** — com links diretos. Complementa o
> [guia principal](GUIA_BC250_CACHYOS_GAMING.md) (seções 2 e 13).
>
> Fontes: documentação oficial de hardware ([cooling guide](https://elektricM.github.io/amd-bc250-docs/hardware/cooling/)),
> catálogo comunitário de cases (143 designs) e projetos no Printables/Thingiverse/MakerWorld/GitHub.
> Atualizado em setembro de 2026.

---

## Índice

1. [Metas de temperatura](#1-metas-de-temperatura)
2. [O dissipador de fábrica](#2-o-dissipador-de-fábrica)
3. [Ventoinhas recomendadas](#3-ventoinhas-recomendadas)
4. [Backplate e VRAM (o lado esquecido)](#4-backplate-e-vram)
5. [Controle de ventoinha no Linux](#5-controle-de-ventoinha-no-linux)
6. [Tabela por orçamento e perfil de uso](#6-orçamento-e-perfil-de-uso)
7. [Cases 3D da comunidade](#7-cases-3d-da-comunidade)
8. [Cases para PSU ATX completa](#8-cases-para-psu-atx-completa)
9. [Console-style, compactos e especiais](#9-console-style-compactos-e-especiais)
10. [Dicas de impressão 3D](#10-dicas-de-impressão-3d)

---

## 1. Metas de temperatura

| Componente | Idle | Carga leve | Gaming | **Máximo** |
|---|---|---|---|---|
| GPU/APU (edge) | 40–50 °C | 50–60 °C | **65–80 °C** | 90 °C |
| CPU (Tctl) | 45–55 °C | 55–65 °C | 70–85 °C | 95 °C |
| Memória (verso) | 40–55 °C | 50–65 °C | 55–70 °C | 80 °C |

- **Ideal em jogos:** GPU entre **70–80 °C** — performance e longevidade.
- **> 85 °C:** throttle. **> 90 °C:** instabilidade e crashes.
- **Carga sustentada (LLM/compute 40 CUs @ 2 GHz):** mesmo com **dual Arctic P12 Max em push-pull**,
  o dissipador de fábrica não dá conta — medido: GPU edge 89,6 °C (pico **107 °C**), CPU 96,7 °C
  (pico TJmax 100 °C), com ~10% de perda de throughput. **Solução:** cap no governor em **1500 MHz**
  (mantém ~83 °C indefinidamente, mantendo ~1.5× do ganho das 40 CUs) ou refrigeração superior.

---

## 2. O dissipador de fábrica

- **Tipo:** torre de aletas de alumínio **passiva**, projetada para **airflow de rack** — em mesa,
  **exige ventoinha ativa** para jogos. Não é opcional.
- **Variantes:** existem versões com **8 ou 9 fileiras de aletas** (um QR code ao lado do conector
  PCIe 8-pin indica a variante de 9). A de aletas mais grossas/menos numerosas tende a esfriar um pouco melhor.
- **Aletas amassadas:** quase toda placa usada vem com aletas tortas. **Endireitar com cuidado**
  (alumínio é mole — na mão, sem ferramenta) rende **5–10 °C** de melhora.
- **Pasta térmica:** em placa de mineração, quase sempre seca. Trocar rende **5–10 °C**.
  Recomendadas: **Arctic MX-4/MX-6**, Thermal Grizzly Kryonaut, Noctua NT-H1, Thermalright TFX —
  e a **PTM7950** (phase-change) é very popular na comunidade. Aplicação: 4 parafusos, álcool
  isopropílico, ponto do tamanho de um grão de ervilha, aperto em **X**.
- **⚠️ Não parafuse ventoinha nas aletas** e **não remova aletas com Dremel/serra** (lascas metálicas
  perto da placa = desastre). Remoção manual de aletas centrais é possível (irreversível, ~10–15 °C),
  mas um **shroud 3D** entrega ganho parecido sem risco. → seção 10.

---

## 3. Ventoinhas recomendadas

| Modelo | Size | RPM máx | Pressão estática | Ruído máx | Perfil |
|---|---|---|---|---|---|
| **Arctic P12 Max** ⭐ | 120 mm | 3300 | **6,9 mm H₂O** | 52,5 dB(A) | Favorita da comunidade — melhor custo/benefício |
| **Arctic P12 Pro** ⭐ | 120 mm | 2100 | **6,9 mm H₂O** | 37,8 dB(A) | Mais fácil de achar; quase mesma performance |
| Arctic P14 PWM | 140 mm | 1700 | 2,4 mm H₂O | 38 dB(A) | Cobre mais área; builds silenciosas |
| Noctua NF-A12x25 | 120 mm | 2000 | 2,34 mm H₂O | **22,6 dB(A)** | Premium, ultra silenciosa (2–3× o preço) |

**Montagem:** sobre o centro do dissipador com **shroud 3D** ou abraçadeiras (zip ties), no header
PWM. Temperatura esperada em jogos: **65–75 °C** (P12 Max) / 70–85 °C (Noctua).

### Dual fan (recomendado para OC e carga pesada)

- **Principal:** 120 mm sobre o centro do heatsink.
- **Secundário:** 80–120 mm soprando o **backplate** (VRAM).
- Combinações testadas: 2× Arctic P12 Max · P14 + P12 · Noctua + 80 mm traseira.
- Wiring: splitter PWM ou o header **J4003** para a segunda.

### Conversão para cooler de torre (avançado)

Usuários montaram coolers **AM4** (ex.: Thermalright Peerless Assassin) com braçadeiras customizadas.
Excelente performance e silêncio, **mas** exige fabricar suporte, pode bloquear o M.2 — só para
experientes. Para o extremo, existe case com **AIO/líquido** da comunidade (seção 9).

---

## 4. Backplate e VRAM

A **GDDR6 fica toda no verso** da placa — sem dissipador fixo e **sem sensor de temperatura**.
Sintomas de VRAM quente: crashes após 30–60 min, artefatos visuais, instabilidade em jogos longos.

**Soluções (combináveis, nesta ordem):**

1. **Thermal pads de 2 mm** sobre os chips do verso (confira a folga da sua placa) + placa/dissipador
   de alumínio por cima. Marcas: Thermalright Odyssey, Arctic, Gelid GP-Ultimate.
   ⚠️ Use apenas materiais **não condutivos**.
2. **Airflow traseiro:** ventes/aberturas do case atrás do backplate; intake direcionando ar para ele.
3. **Ventoinha secundária 80–120 mm** soprando o backplate (o mais eficaz) — 50–100% contínuo,
   no header J4003 ou splitter.
4. Kit pronto da comunidade: **[OC vRAM Fan Kit (MTSquar3D)](https://www.thingiverse.com/thing:7271946)**
   (remix do design do Arthrimus, com suporte de fan para o verso).

> ✅ **Prática recomendada:** pads de 2 mm + airflow traseiro no mínimo. Backplate sem fluxo de ar é
> a causa nº 1 de "crash depois de meia hora de jogo".

---

## 5. Controle de ventoinha no Linux

O chip da placa é o **NCT6686D**. O módulo de kernel `nct6683` é **somente leitura** — para
**controlar PWM** instale o `nct6687` ([Fred78290/nct6687d](https://github.com/Fred78290/nct6687d)):

```bash
git clone https://github.com/Fred78290/nct6687d.git
cd nct6687d && make && sudo make install

echo 'blacklist nct6683' | sudo tee /etc/modprobe.d/sensors.conf
echo 'options nct6687 force=true' | sudo tee -a /etc/modprobe.d/sensors.conf
echo 'nct6687' | sudo tee /etc/modules-load.d/99-sensors.conf

sudo mkinitcpio -P        # Arch/CachyOS  (Fedora: sudo dracut --regenerate-all --force)
sudo reboot
```

> 🔌 **Mapeamento:** a ventoinha principal vai no header **Pump Fan** = `fan2`/`pwm2` no sysfs.
> `CPU Fan` (fan1) e `System Fan` (fan3+) costumam ficar livres.

**Controle manual (teste):**

```bash
HWMON=$(grep -l nct6686 /sys/class/hwmon/hwmon*/name | head -1 | xargs dirname)
echo 1   | sudo tee $HWMON/pwm2_enable   # modo manual
echo 200 | sudo tee $HWMON/pwm2          # ~78% (0–255)
```

**Curvas com GUI:** [CoolerControl](https://gitlab.com/coolercontrol/coolercontrol) —
`yay -S coolercontrol` (Arch/CachyOS) ou `ujust install-coolercontrol` (Bazzite). Web UI em
`https://localhost:11987`. Crie a curva no **pwm2** usando **k10temp (Tctl)** como fonte.

**Alternativa leve — curva por script systemd:**

```bash
sudo tee /usr/local/bin/bc250-fancurve << 'SCRIPT'
#!/bin/bash
HWMON_PWM=/sys/class/hwmon/hwmon1/pwm2
HWMON_ENABLE=/sys/class/hwmon/hwmon1/pwm2_enable
TEMP_INPUT=/sys/class/hwmon/hwmon3/temp1_input
echo 1 > $HWMON_ENABLE
while true; do
    TEMP=$(($(cat $TEMP_INPUT) / 1000))
    if [ $TEMP -le 40 ]; then PWM=60
    elif [ $TEMP -le 50 ]; then PWM=80
    elif [ $TEMP -le 60 ]; then PWM=120
    elif [ $TEMP -le 70 ]; then PWM=160
    elif [ $TEMP -le 80 ]; then PWM=200
    elif [ $TEMP -le 85 ]; then PWM=230
    else PWM=255; fi
    echo $PWM > $HWMON_PWM
    sleep 3
done
SCRIPT
sudo chmod +x /usr/local/bin/bc250-fancurve
```

> ⚠️ A numeração `hwmon*` muda entre kernels/boots — confirme com
> `cat /sys/class/hwmon/hwmon*/name` (nct6686 = controle, k10temp = temperatura).

**Modos da BIOS:** Default (mínimo 40% — insuficiente), **Full Speed** (100% — seguro e barulhento)
e Customize (curva própria). ⚠️ **Não use BIOS Customize + CoolerControl juntos** — eles brigam
pelo controle.

---

## 6. Orçamento e perfil de uso

| Orçamento | Solução | Temp. esperada |
|---|---|---|
| **Mínimo** | 1× Arctic P12 presa com zip tie + shroud de papelão | 75–85 °C |
| **Budget** | Arctic P12 Max + shroud 3D + pasta nova | 70–80 °C |
| **Padrão** | Dual Arctic P12 + shroud + pasta + pads de VRAM | **65–75 °C** |
| **Premium** | Noctua + case alumínio + PTM7950 + cooling de RAM | 60–70 °C |
| **Entusiasta** | Cooler de torre AM4 / water cooling custom | 55–65 °C |

| Uso | Recomendação |
|---|---|
| 🎮 **Gaming** | Arctic P12 Max/Pro, curva custom ou BIOS full speed — 70–80 °C |
| 🤫 **Silencioso** | Noctua NF-A12x25 + curva (máx 60%) — aceita 75–85 °C |
| 📦 **Compacto** | 1× 120 mm integrado ao case 3D — menos folga térmica |
| 🤖 **LLM/compute 24/7** | Dual 120 mm + filtros de poeira; cap 1500 MHz com 40 CUs |

---

## 7. Cases 3D da comunidade

A comunidade mantém um **catálogo com 143 designs** documentados (Discord, Reddit, Printables,
MakerWorld, Thingiverse…), com filtro por tipo de fonte, disponibilidade e plataforma:

- 🔎 **Catálogo oficial interativo:** https://elektricM.github.io/amd-bc250-docs/community/cases/
- 🔎 **Busca no Printables:** https://www.printables.com/search/models?q=BC-250
- 🔎 **Agregador (yeggi):** https://www.yeggi.com/q/amd+bc250/

**Por tipo de fonte (54 designs públicos/gratuitos):** FlexATX **30** · MeanWell LOP 8 · **Full ATX 7** ·
LRS/UHP 3 · HP Server 2 · TFX 1 · outros/líquido/VESA 3.

> 💡 **Como escolher:** o fator decisivo é a **fonte**. Sem fonte → case FlexATX (o mais comum, ~30
> designs, incluindo os console-style). Já tem fonte ATX boa sobrando → seção 8. Fonte server/HP ou
> MeanWell → catálogo. Quer zero impressão? Há designs "off-the-shelf" (caixas metálicas) no catálogo.

---

## 8. Cases para PSU ATX completa

Reaproveitar uma **fonte ATX** que você já tem é o caminho mais econômico — e estes são os
**7 designs públicos e gratuitos** catalogados pela comunidade:

| Projeto | Autor | Link | Destaque |
|---|---|---|---|
| **BC-250 ATX PSU Bazzite Box** | gennro | [Printables #1550729](https://www.printables.com/model/1550729) | Pensado pro setup Bazzite |
| **AMD BC-250 Case for Standard ATX** | CatSiewDai | [Printables #1553599](https://www.printables.com/model/1553599) | ATX padrão |
| **Dual Fan BC-250 ATX CASE** | Mateo Fdez | [Printables #1579658](https://www.printables.com/model/1579658) | **Dual fan** — melhor refrigeração |
| **AMD BC-250 Case ATX + Fan Duct** | ZMASLO | [Printables #1616167](https://www.printables.com/model/1616167) | **Duct de fan** guiando ar ao heatsink |
| **BC-250 Simple Wooden Case** | suvalle55 | [Printables #1595794](https://www.printables.com/model/1595794) | Híbrido madeira + impressão |
| **Open Frame Case + IKEA Hack** | GreatApo | [Thingiverse #7314188](https://www.thingiverse.com/thing:7314188) | Open frame com peças IKEA |
| **AMD BC250 Case for ATX PSU** | matmiak | [Thingiverse #7303096](https://www.thingiverse.com/thing:7303096) | Com furo p/ switch (resin) |

> 💡 Para refrigeração máxima num case ATX, priorize o **Dual Fan (Mateo Fdez)** ou o
> **ATX + Fan Duct (ZMASLO)** — os dois resolvem o airflow do heatsink e deixam espaço para
> ventoinha no backplate.

---

## 9. Console-style, compactos e especiais

**O clássico console-style (FlexATX)** — a linha que popularizou a "Steam Machine de pobre":

| Projeto | Autor | Link | Nota |
|---|---|---|---|
| **Console Style Case v1** | Arthrimus | [Thingiverse #7165679](https://www.thingiverse.com/thing:7165679) | O design de referência |
| **Slim Console Style Case** | Arthrimus | [Thingiverse #7172528](https://www.thingiverse.com/thing:7172528) | Versão slim, com botão power e USB frontal |
| **Slim Console – double fan mod** | TKXXTH | [Thingiverse #7214884](https://www.thingiverse.com/thing:7214884) | Remix com **dual fan** |
| **DIY Steam Machine v3** | NexGen-3D | [Printables #1499974](https://www.printables.com/model/1499974) | Do autor do toolkit padrão do Bazzite |
| **"Steam Machine" (MrLarva)** | MrLarva | [Printables #1618501](https://www.printables.com/model/1618501) · [v2](https://www.thingiverse.com/thing:7304454) | Muito popular |
| **Steam Machine Slim** | MTSquar3D | [Thingiverse #7271946](https://www.thingiverse.com/thing:7271946) | + kit de fan para VRAM |
| **CUSTOM CASE (Flex PSU)** | isaacalvex | [Thingiverse #7201620](https://www.thingiverse.com/thing:7201620) | Alternativa robusta |
| **Minimal Case (Toolless)** | chriszf | [Printables #1423572](https://www.printables.com/model/1423572) | **Sem parafusos** |
| **Minimalist BC-250 Case** | SebastienGau | [Printables #1581724](https://www.printables.com/model/1581724) | Minimalista |
| **BC-250 case V4 (FlexATX + HP)** | Hrumque | [MakerWorld #2481620](https://makerworld.com/en/models/2481620) | FlexATX **ou** PSU HP server |

**Outros destaques:**

- 💧 **Liquid/AIO:** [NexGen3D Pro – Liquid Cooled](https://www.printables.com/model/1614131) — para quem quer o extremo do silêncio/temperatura.
- 🧩 **GitHub (código aberto):** [bc-250-sleeve-adapter](https://github.com/onemorecap/bc-250-sleeve-adapter) (adaptador 120 mm) e [bc-250-shell-case](https://github.com/onemorecap/bc-250-shell-case) (enclosure completo, linha MeanWell LOP).
- 🖥️ **Fontes especiais:** MeanWell LOP/LRS (8+3 designs), HP Server PSU (2), TFX (1 remix) — filtre no [catálogo oficial](https://elektricM.github.io/amd-bc250-docs/community/cases/).
- 🖨️ **Top cover com fan 120 mm:** [praeterita](https://www.printables.com/model/1514874).
- ♻️ **E-waste Steam Machine:** [Pesen333](https://www.thingiverse.com/thing:7245584).

---

## 10. Dicas de impressão 3D

- **Filamento:** **PETG** (calor + rigidez) ou PLA (ok para builds frescas); ABS/ASA se for deixar no sol/quente.
- **Parâmetros típicos da comunidade:** camada **0,2 mm**, infill **20–30%**, 3–4 paredes.
- **Verifique antes de imprimir:** folga do **shroud da ventoinha** (não pode encostar nas aletas), passagem do **conector PCIe 8-pin**, ventilação do **backplate**, e se o design comporta **sua fonte** (FlexATX ≠ ATX ≠ SFX).
- **Botão power/USB frontal:** os designs do Arthrimus já têm provisões; há remixes com botão ATX padrão (ex.: [BlessedNoob](https://www.thingiverse.com/thing:7309665)).
- **Ventoinha:** case bom + P12 Max + pasta nova + pads no verso ≈ o combo padrão da comunidade (65–75 °C em jogos).
- **Shroud em vez de cirurgia:** preferível a remover aletas — mesmo ganho prático, zero risco.

---

## Fontes

- **Documentação oficial de cooling:** https://elektricM.github.io/amd-bc250-docs/hardware/cooling/
- **Catálogo de cases (143 designs):** https://elektricM.github.io/amd-bc250-docs/community/cases/ ([dados](https://github.com/elektricM/amd-bc250-docs/blob/main/docs/community/cases-data.json))
- **Módulo de fan control:** https://github.com/Fred78290/nct6687d
- **Comunidade:** [r/BC250Gaming](https://www.reddit.com/r/BC250Gaming/) · [Discord da BC-250](https://discord.gg/8eZfFWhczz) · Printables · Thingiverse · MakerWorld

---

*Parte do projeto [BC-250 × CachyOS — Guia Definitivo de Gaming](README.md) · conteúdo original em PT-BR, licença MIT · dados de refrigeração da documentação da comunidade (CC BY-SA 4.0).*
