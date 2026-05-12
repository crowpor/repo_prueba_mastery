#!/bin/bash

################################################################################
# WireGuard Manager Script
# Descripción: Script para gestionar conexiones VPN WireGuard usando nmcli
# Autor: Crowpor
# Licencia: MIT
################################################################################

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VPN_CONNECTION_NAME="wireguard-vpn"

# Función para mostrar mensajes
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para verificar si el script se ejecuta como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Este script debe ejecutarse como root (use sudo)"
        exit 1
    fi
}

# Función para instalar WireGuard
install_wireguard() {
    log_info "Instalando WireGuard..."
    
    # Detectar distribución
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        log_error "No se pudo detectar la distribución del sistema"
        exit 1
    fi
    
    case $OS in
        ubuntu|debian)
            log_info "Detectado sistema basado en Debian/Ubuntu"
            apt-get update
            apt-get install -y wireguard wireguard-tools network-manager
            ;;
        fedora|centos|rhel)
            log_info "Detectado sistema basado en RedHat/Fedora"
            dnf install -y wireguard-tools NetworkManager NetworkManager-tui
            ;;
        arch|manjaro)
            log_info "Detectado sistema basado en Arch"
            pacman -Sy --noconfirm wireguard-tools networkmanager
            ;;
        *)
            log_error "Distribución no soportada: $OS"
            exit 1
            ;;
    esac
    
    log_info "WireGuard instalado correctamente"
}

# Función para importar configuración de WireGuard
import_wireguard_config() {
    local conf_file=$1
    
    if [ -z "$conf_file" ]; then
        log_error "Debe especificar un archivo de configuración .conf"
        exit 1
    fi
    
    if [ ! -f "$conf_file" ]; then
        log_error "El archivo $conf_file no existe"
        exit 1
    fi
    
    log_info "Importando configuración desde $conf_file..."
    
    # Eliminar conexión existente si existe
    if nmcli connection show "$VPN_CONNECTION_NAME" &> /dev/null; then
        log_warning "Eliminando conexión existente..."
        nmcli connection delete "$VPN_CONNECTION_NAME"
    fi
    
    # Importar configuración usando nmcli
    if ! nmcli connection import type wireguard file "$conf_file"; then
        log_error "Fallo al importar la configuración. Verifica que el archivo sea válido y que WireGuard esté instalado correctamente."
        exit 1
    fi
    
    # Renombrar la conexión para tener un nombre consistente
    local imported_name="$(basename "$conf_file" .conf)"
    if [ "$imported_name" != "$VPN_CONNECTION_NAME" ]; then
        nmcli connection modify "$imported_name" connection.id "$VPN_CONNECTION_NAME"
    fi
    
    # Deshabilitar autoconexión por defecto
    nmcli connection modify "$VPN_CONNECTION_NAME" connection.autoconnect no
    
    log_info "Configuración importada correctamente como '$VPN_CONNECTION_NAME'"
}

# Función para activar la VPN
vpn_up() {
    log_info "Activando conexión VPN..."
    
    if ! nmcli connection show "$VPN_CONNECTION_NAME" &> /dev/null; then
        log_error "La conexión '$VPN_CONNECTION_NAME' no existe. Primero importa una configuración."
        exit 1
    fi
    
    if nmcli connection show --active | grep -q "$VPN_CONNECTION_NAME"; then
        log_warning "La VPN ya está activa"
        return 0
    fi
    
    nmcli connection up "$VPN_CONNECTION_NAME"
    log_info "VPN activada correctamente"
}

# Función para desactivar la VPN
vpn_down() {
    log_info "Desactivando conexión VPN..."
    
    if ! nmcli connection show "$VPN_CONNECTION_NAME" &> /dev/null; then
        log_error "La conexión '$VPN_CONNECTION_NAME' no existe"
        exit 1
    fi
    
    if ! nmcli connection show --active | grep -q "$VPN_CONNECTION_NAME"; then
        log_warning "La VPN ya está desactivada"
        return 0
    fi
    
    nmcli connection down "$VPN_CONNECTION_NAME"
    log_info "VPN desactivada correctamente"
}

# Función para ver el estado de la VPN
vpn_status() {
    log_info "Estado de la VPN:"
    
    if ! nmcli connection show "$VPN_CONNECTION_NAME" &> /dev/null; then
        echo "  Estado: No configurada"
        return 0
    fi
    
    if nmcli connection show --active | grep -q "$VPN_CONNECTION_NAME"; then
        echo -e "  Estado: ${GREEN}Activa${NC}"
    else
        echo -e "  Estado: ${RED}Inactiva${NC}"
    fi
    
    # Mostrar información de la conexión
    echo ""
    nmcli connection show "$VPN_CONNECTION_NAME" | grep -E "connection\.(id|autoconnect)|wireguard"
}

# Función para habilitar/deshabilitar autoconexión
toggle_autoconnect() {
    local action=$1
    
    if ! nmcli connection show "$VPN_CONNECTION_NAME" &> /dev/null; then
        log_error "La conexión '$VPN_CONNECTION_NAME' no existe"
        exit 1
    fi
    
    if [ "$action" = "enable" ]; then
        nmcli connection modify "$VPN_CONNECTION_NAME" connection.autoconnect yes
        log_info "Autoconexión habilitada"
    elif [ "$action" = "disable" ]; then
        nmcli connection modify "$VPN_CONNECTION_NAME" connection.autoconnect no
        log_info "Autoconexión deshabilitada"
    else
        log_error "Acción no válida. Use 'enable' o 'disable'"
        exit 1
    fi
}

# Función para crear enlaces simbólicos
create_symlinks() {
    log_info "Creando enlaces simbólicos..."
    
    # Crear scripts individuales para up y down
    cat > "${SCRIPT_DIR}/vpn-up.sh" << 'EOF'
#!/bin/bash
VPN_CONNECTION_NAME="wireguard-vpn"
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse como root (use sudo)"
    exit 1
fi
nmcli connection up "$VPN_CONNECTION_NAME"
echo "VPN activada"
EOF

    cat > "${SCRIPT_DIR}/vpn-down.sh" << 'EOF'
#!/bin/bash
VPN_CONNECTION_NAME="wireguard-vpn"
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse como root (use sudo)"
    exit 1
fi
nmcli connection down "$VPN_CONNECTION_NAME"
echo "VPN desactivada"
EOF

    chmod +x "${SCRIPT_DIR}/vpn-up.sh"
    chmod +x "${SCRIPT_DIR}/vpn-down.sh"
    
    # Crear enlaces simbólicos en /usr/local/bin
    ln -sf "${SCRIPT_DIR}/vpn-up.sh" /usr/local/bin/vpn-up
    ln -sf "${SCRIPT_DIR}/vpn-down.sh" /usr/local/bin/vpn-down
    
    log_info "Enlaces simbólicos creados:"
    log_info "  - vpn-up: sudo vpn-up"
    log_info "  - vpn-down: sudo vpn-down"
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
Uso: $0 [COMANDO] [OPCIONES]

Comandos:
  install                    Instala WireGuard y dependencias
  import <archivo.conf>      Importa configuración WireGuard desde archivo .conf
  up                        Activa la conexión VPN
  down                      Desactiva la conexión VPN
  status                    Muestra el estado de la VPN
  autoconnect enable|disable Habilita/deshabilita la autoconexión
  create-symlinks           Crea enlaces simbólicos vpn-up y vpn-down
  help                      Muestra esta ayuda

Ejemplos:
  # Instalación completa
  sudo $0 install
  sudo $0 import /path/to/wg0.conf
  sudo $0 create-symlinks
  
  # Gestión de la VPN
  sudo $0 up
  sudo $0 down
  sudo $0 status
  
  # Usando enlaces simbólicos
  sudo vpn-up
  sudo vpn-down
  
  # Autoconexión
  sudo $0 autoconnect disable

EOF
}

# Main
if [ -z "$1" ]; then
    log_error "Debe especificar un comando"
    echo ""
    show_help
    exit 1
fi

case "$1" in
    install)
        check_root
        install_wireguard
        ;;
    import)
        check_root
        import_wireguard_config "$2"
        ;;
    up)
        check_root
        vpn_up
        ;;
    down)
        check_root
        vpn_down
        ;;
    status)
        vpn_status
        ;;
    autoconnect)
        check_root
        toggle_autoconnect "$2"
        ;;
    create-symlinks)
        check_root
        create_symlinks
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Comando no válido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
