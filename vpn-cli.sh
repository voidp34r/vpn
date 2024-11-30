#!/bin/bash

# CLI para configurar VPN com rotas específicas no macOS.
# Desenvolvido para evitar impactos em outras configurações do sistema.

# Constantes
VPN_ROUTES=(
  "172.21.0.190 192.168.11.27"
  "172.21.0.192 192.168.11.27"
  "172.18.255.5 192.168.11.27"
)
VPN_INTERFACE="ppp0"
SCRIPT_PATH="/etc/vpn-routes.sh"
LOG_FILE="/var/log/vpn-cli.log"

# Funções Utilitárias
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

error() {
  echo "Erro: $1" >&2
  exit 1
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "Este script precisa ser executado como root. Use sudo."
  fi
}

# Funções Principais
install_routes() {
  log "Instalando rotas específicas da VPN..."
  
  # Criar o script de rotas
  cat <<EOF >"$SCRIPT_PATH"
#!/bin/bash
# Script para configurar rotas da VPN
EOF

  for route in "${VPN_ROUTES[@]}"; do
    echo "sudo route -n add $route" >>"$SCRIPT_PATH"
  done

  chmod +x "$SCRIPT_PATH"
  
  # Executar o script pela primeira vez
  "$SCRIPT_PATH" || error "Falha ao aplicar as rotas."

  log "Rotas configuradas com sucesso. Script salvo em $SCRIPT_PATH"
}

uninstall_routes() {
  log "Removendo rotas específicas da VPN..."

  for route in "${VPN_ROUTES[@]}"; do
    IP=$(echo "$route" | awk '{print $1}')
    sudo route -n delete "$IP" || log "A rota para $IP já foi removida."
  done

  rm -f "$SCRIPT_PATH" || log "O script de rotas já foi removido."
  
  log "Rotas removidas com sucesso."
}

doctor() {
  log "Executando checagem (doctor)..."

  for route in "${VPN_ROUTES[@]}"; do
    IP=$(echo "$route" | awk '{print $1}')
    if ! netstat -rn | grep -q "$IP"; then
      log "Rota para $IP não está configurada."
      return 1
    fi
  done

  log "Todas as rotas estão configuradas corretamente."
  return 0
}

help_menu() {
  cat <<EOF
Uso: vpn-cli.sh [comando]
Comandos disponíveis:
  install     - Instalar as rotas específicas da VPN
  uninstall   - Remover as rotas específicas da VPN
  doctor      - Verificar o estado das rotas (checagem)
  help        - Mostrar este menu de ajuda
EOF
}

# Lógica Principal
main() {
  check_root
  
  case "$1" in
    install)
      install_routes
      ;;
    uninstall)
      uninstall_routes
      ;;
    doctor)
      doctor
      ;;
    help|*)
      help_menu
      ;;
  esac
}

main "$@"