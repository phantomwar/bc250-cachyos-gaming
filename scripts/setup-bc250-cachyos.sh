#!/usr/bin/env bash
# =============================================================================
#  setup-bc250-cachyos.sh
#  Script auxiliar de pós-instalação do AMD BC-250 no CachyOS.
#  Automatiza os passos recorrentes, APONTANDO para os repositórios já
#  clonados neste diretório de trabalho (../repos/...).
#
#  AVISO: leia e revise antes de rodar. Overclock e unlocks elevam calor e
#  consumo. Você é responsável pela sua fonte e refrigeração.
#
#  Uso:
#    chmod +x setup-bc250-cachyos.sh
#    sudo ./setup-bc250-cachyos.sh            # menu interativo
#    sudo ./setup-bc250-cachyos.sh --check    # só verificação
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/repos"
GOV_SMU="cyan-skillfish-governor-smu"

log()  { echo -e "\e[1;34m[BC250]\e[0m $*"; }
warn() { echo -e "\e[1;33m[AVISO]\e[0m $*"; }
err()  { echo -e "\e[1;31m[ERRO]\e[0m $*"; }

check_prereqs() {
  command -v yay >/dev/null 2>&1 || warn "yay não encontrado (necessário para pacotes AUR)."
  [[ -d "$REPO_ROOT" ]] || warn "Diretório de repos não encontrado em: $REPO_ROOT"
}

install_gpu_governor() {
  log "Instalando GPU governor ($GOV_SMU) ..."
  yay -S --noconfirm "$GOV_SMU" || warn "Falha ao instalar $GOV_SMU. Tente: yay -S $GOV_SMU"
  sudo systemctl enable --now "$GOV_SMU.service" || true
  systemctl status "$GOV_SMU.service" --no-pager || true
}

install_sensors_gaming() {
  log "Instalando sensores + ferramentas de gaming ..."
  sudo pacman -S --needed --noconfirm lm_sensors steam mangohud goverlay gamemode gamescope nvtop htop fastfetch protonup-qt
  echo 'nct6683' | sudo tee /etc/modules-load.d/nct6683.conf >/dev/null
  echo 'options nct6683 force=true' | sudo tee /etc/modprobe.d/sensors.conf >/dev/null
  sudo mkinitcpio -P
  log "Sensores configurados. Reinicie para ativar o módulo nct6683."
}

set_kernel_params() {
  log "Aplicando mitigations=off no GRUB ..."
  sudo mkdir -p /etc/default/grub.d
  echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet mitigations=off"' | sudo tee /etc/default/grub.d/user.cfg >/dev/null
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  log "Parâmetros definidos. Reinicie para aplicar."
}

install_acpi_8core() {
  log "Instalando fix ACPI 8-core (C-states + P-states) ..."
  local dir=/etc/initcpio/acpi_override
  sudo mkdir -p "$dir"
  sudo cp "$REPO_ROOT/bc250-acpi-fix-updated-8c/SSDT-CST.aml" "$dir/" 2>/dev/null || warn "SSDT-CST.aml não encontrado."
  sudo cp "$REPO_ROOT/bc250-acpi-fix-updated-8c/SSDT-PST.aml" "$dir/" 2>/dev/null || warn "SSDT-PST.aml não encontrado."
  sudo sed -i '/^HOOKS=/ { /acpi_override/q; s/microcode/& acpi_override/; q }' /etc/mkinitcpio.conf
  sudo mkinitcpio -P
  log "ACPI fix aplicado. Reinicie. Verifique com: cpupower idle-info"
}

unlock_cores() {
  log "Destravando 8 núcleos (via GabriWar/bc250-core-cu-unlock) ..."
  local d="$REPO_ROOT/bc250-core-cu-unlock"
  [[ -f "$d/bc250-8core-unlock.sh" ]] || { err "Script não encontrado em $d"; return 1; }
  ( cd "$d" && sudo ./bc250-8core-unlock.sh status )
  read -r -p "Aplicar unlock agora? Depois de rodar, VOCÊ escolhe quando reiniciar. [s/N] " ans
  if [[ "${ans:-n}" =~ ^[sSyY]$ ]]; then
    ( cd "$d" && sudo ./bc250-8core-unlock.sh apply )
    warn "Agora reinicie (sudo reboot) — NÃO deixe scripts reiniciarem sozinhos."
  fi
}

unlock_40cu() {
  log "Destravando 40 CUs (duggasco/bc250-40cu-unlock) ..."
  local d="$REPO_ROOT/bc250-40cu-unlock"
  [[ -f "$d/scripts/bc250-enable-40cu-arch.sh" ]] || { err "Script 40 CU não encontrado em $d/scripts"; return 1; }
  ( cd "$d" && sudo bash scripts/bc250-enable-40cu-arch.sh build )
  read -r -p "Ativar agora (grava modprobe e reinicia)? [s/N] " ans
  if [[ "${ans:-n}" =~ ^[sSyY]$ ]]; then
    ( cd "$d" && sudo bash scripts/bc250-enable-40cu-arch.sh enable )
  fi
}

setup_check() {
  log "===== Verificação do sistema ====="
  echo "Kernel:  $(uname -r)"
  echo "Mesa:    $(glxinfo 2>/dev/null | grep -i 'OpenGL version' || echo 'N/D')"
  echo "GPU:     $(vulkaninfo 2>/dev/null | grep deviceName || echo 'N/D')"
  echo "Gov SMU: $(systemctl is-active "$GOV_SMU.service" 2>/dev/null || echo 'inativo')"
  echo "C-states: $(cpupower idle-info 2>/dev/null | grep -c 'state[0-9]' || echo 'N/D')"
  echo "CPUs:    $(lscpu 2>/dev/null | grep '^CPU(s)' || echo 'N/D')"
  echo "CU ativas (dmesg): $(sudo dmesg 2>/dev/null | grep -o 'active_cu_number [0-9]*' | tail -1 || echo 'N/D')"
  echo "FreQ GPU: $(cat /sys/class/drm/card0/device/pp_dpm_sclk 2>/dev/null | tr '\n' ' ' || echo 'N/D')"
  echo "=================================="
}

menu() {
  echo "== Setup BC-250 CachyOS =="
  echo " 1) GPU governor (SMU)"
  echo " 2) Sensores + ferramentas de gaming"
  echo " 3) Parâmetros de kernel (mitigations=off)"
  echo " 4) Fix ACPI 8-core"
  echo " 5) Unlock 8 núcleos"
  echo " 6) Unlock 40 CUs"
  echo " C) Check status"
  echo " A) Rodar 1-4 sequência segura"
  echo " 0) Sair"
  read -r -p "Escolha: " c
  case "$c" in
    1) install_gpu_governor;;
    2) install_sensors_gaming;;
    3) set_kernel_params;;
    4) install_acpi_8core;;
    5) unlock_cores;;
    6) unlock_40cu;;
    C|c) setup_check;;
    A|a) install_gpu_governor; install_sensors_gaming; set_kernel_params; install_acpi_8core;;
    0) exit 0;;
    *) err "Opção inválida";;
  esac
}

[[ "${1:-}" == "--check" ]] && { check_prereqs; setup_check; exit 0; }
check_prereqs
menu
