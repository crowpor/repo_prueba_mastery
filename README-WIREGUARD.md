# WireGuard VPN Manager

Script completo para gestionar conexiones VPN WireGuard en Linux usando NetworkManager (nmcli).

## Características

- ✅ Instalación automática de WireGuard
- ✅ Importación de archivos de configuración `.conf`
- ✅ Gestión de conexiones VPN (activar/desactivar)
- ✅ Control de autoconexión automática
- ✅ Enlaces simbólicos para comandos rápidos
- ✅ Compatible con múltiples distribuciones Linux

## Requisitos Previos

- Sistema Linux con NetworkManager instalado
- Permisos de superusuario (root/sudo)
- Distribuciones soportadas:
  - Ubuntu/Debian
  - Fedora/CentOS/RHEL
  - Arch Linux/Manjaro

## Instalación Rápida

### 1. Clonar o descargar el script

```bash
git clone https://github.com/crowpor/repo_prueba_mastery.git
cd repo_prueba_mastery
chmod +x wireguard-manager.sh
```

### 2. Instalar WireGuard

```bash
sudo ./wireguard-manager.sh install
```

### 3. Importar configuración de WireGuard

Necesitas tener un archivo de configuración WireGuard (`.conf`). Por ejemplo:

```bash
sudo ./wireguard-manager.sh import /ruta/a/tu/archivo.conf
```

### 4. Crear enlaces simbólicos (opcional pero recomendado)

```bash
sudo ./wireguard-manager.sh create-symlinks
```

Esto crea los comandos globales `vpn-up` y `vpn-down`.

## Uso

### Comandos del script principal

```bash
# Ver ayuda
./wireguard-manager.sh help

# Instalar WireGuard
sudo ./wireguard-manager.sh install

# Importar configuración
sudo ./wireguard-manager.sh import /ruta/archivo.conf

# Activar VPN
sudo ./wireguard-manager.sh up

# Desactivar VPN
sudo ./wireguard-manager.sh down

# Ver estado de la VPN
./wireguard-manager.sh status

# Habilitar autoconexión
sudo ./wireguard-manager.sh autoconnect enable

# Deshabilitar autoconexión
sudo ./wireguard-manager.sh autoconnect disable

# Crear enlaces simbólicos
sudo ./wireguard-manager.sh create-symlinks
```

### Usando enlaces simbólicos

Una vez creados los enlaces simbólicos, puedes usar comandos más cortos desde cualquier lugar:

```bash
# Activar VPN
sudo vpn-up

# Desactivar VPN
sudo vpn-down
```

## Ejemplo de Archivo de Configuración WireGuard

Crea un archivo `wg0.conf` con el siguiente formato:

```ini
[Interface]
PrivateKey = TU_CLAVE_PRIVADA_AQUI
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = CLAVE_PUBLICA_DEL_SERVIDOR
Endpoint = vpn.ejemplo.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

## Flujo de Trabajo Típico

### Primera vez

```bash
# 1. Instalar WireGuard
sudo ./wireguard-manager.sh install

# 2. Importar tu configuración
sudo ./wireguard-manager.sh import ~/mi-vpn.conf

# 3. Crear enlaces simbólicos para facilitar el uso
sudo ./wireguard-manager.sh create-symlinks

# 4. Activar la VPN
sudo vpn-up
```

### Uso diario

```bash
# Conectar a la VPN
sudo vpn-up

# Verificar estado
./wireguard-manager.sh status

# Desconectar de la VPN
sudo vpn-down
```

## Gestión de Autoconexión

Por defecto, la autoconexión está **deshabilitada**. Esto significa que la VPN no se conectará automáticamente al iniciar el sistema.

### Habilitar autoconexión

```bash
sudo ./wireguard-manager.sh autoconnect enable
```

La VPN se conectará automáticamente cuando el sistema inicie.

### Deshabilitar autoconexión

```bash
sudo ./wireguard-manager.sh autoconnect disable
```

La VPN solo se conectará manualmente cuando lo solicites.

## Solución de Problemas

### La VPN no se conecta

1. Verifica que WireGuard esté instalado:
   ```bash
   which wg
   ```

2. Verifica que la configuración esté importada:
   ```bash
   nmcli connection show
   ```

3. Revisa los logs del sistema:
   ```bash
   sudo journalctl -u NetworkManager -f
   ```

### Verificar estado de NetworkManager

```bash
systemctl status NetworkManager
```

Si no está ejecutándose:

```bash
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
```

### Permisos insuficientes

Todos los comandos de gestión (excepto `status`) requieren permisos de root:

```bash
sudo ./wireguard-manager.sh [comando]
```

## Estructura de Archivos

Después de la instalación completa:

```
repo_prueba_mastery/
├── wireguard-manager.sh    # Script principal
├── vpn-up.sh              # Script para activar VPN (creado por create-symlinks)
├── vpn-down.sh            # Script para desactivar VPN (creado por create-symlinks)
└── README-WIREGUARD.md    # Esta documentación

Enlaces simbólicos en /usr/local/bin/:
├── vpn-up -> /ruta/completa/a/vpn-up.sh
└── vpn-down -> /ruta/completa/a/vpn-down.sh
```

## Características de Seguridad

- El script verifica permisos de root antes de realizar cambios
- Los archivos de configuración deben tener permisos apropiados (600 recomendado)
- La autoconexión está deshabilitada por defecto para mayor control

## Desinstalación

Para eliminar la conexión VPN:

```bash
sudo nmcli connection delete wireguard-vpn
```

Para eliminar los enlaces simbólicos:

```bash
sudo rm /usr/local/bin/vpn-up
sudo rm /usr/local/bin/vpn-down
```

Para desinstalar WireGuard (Ubuntu/Debian):

```bash
sudo apt-get remove wireguard wireguard-tools
```

## Licencia

MIT License - Ver archivo LICENSE

## Autor

Crowpor

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request.

## Soporte

Para reportar problemas o solicitar características, por favor abre un issue en:
https://github.com/crowpor/repo_prueba_mastery/issues
