# Guía de Inicio Rápido - WireGuard VPN Manager

## 🚀 Instalación en 3 Pasos

### Paso 1: Preparar el script
```bash
# Clonar el repositorio (si aún no lo has hecho)
git clone https://github.com/crowpor/repo_prueba_mastery.git
cd repo_prueba_mastery

# El script ya tiene permisos de ejecución
# Si no: chmod +x wireguard-manager.sh
```

### Paso 2: Instalar WireGuard
```bash
sudo ./wireguard-manager.sh install
```

### Paso 3: Configurar tu VPN
```bash
# Importar tu archivo de configuración
sudo ./wireguard-manager.sh import /ruta/a/tu/archivo.conf

# Crear enlaces simbólicos para facilitar el uso
sudo ./wireguard-manager.sh create-symlinks
```

## 🎯 Uso Diario

### Activar la VPN
```bash
sudo vpn-up
```

### Desactivar la VPN
```bash
sudo vpn-down
```

### Ver estado
```bash
./wireguard-manager.sh status
```

## 📋 Comandos Disponibles

| Comando | Descripción | Requiere sudo |
|---------|-------------|---------------|
| `install` | Instala WireGuard y dependencias | ✅ |
| `import <archivo.conf>` | Importa configuración de WireGuard | ✅ |
| `up` | Activa la VPN | ✅ |
| `down` | Desactiva la VPN | ✅ |
| `status` | Muestra el estado actual | ❌ |
| `autoconnect enable` | Habilita conexión automática | ✅ |
| `autoconnect disable` | Deshabilita conexión automática | ✅ |
| `create-symlinks` | Crea enlaces vpn-up y vpn-down | ✅ |
| `help` | Muestra ayuda completa | ❌ |

## 🔧 Configuración Inicial Completa

```bash
# 1. Instalar WireGuard
sudo ./wireguard-manager.sh install

# 2. Copiar tu archivo de configuración al servidor
# (Ejemplo: tienes un archivo llamado mi-vpn.conf)
# Puedes usar el archivo wg0.conf.example como plantilla

# 3. Importar la configuración
sudo ./wireguard-manager.sh import ./mi-vpn.conf

# 4. Crear enlaces simbólicos
sudo ./wireguard-manager.sh create-symlinks

# 5. Probar la conexión
sudo vpn-up
./wireguard-manager.sh status
sudo vpn-down
```

## 📝 Crear tu Archivo de Configuración

Si no tienes un archivo `.conf`, edita el archivo `wg0.conf.example` incluido:

```bash
# 1. Copiar el ejemplo
cp wg0.conf.example mi-vpn.conf

# 2. Editar con tu información
nano mi-vpn.conf
# o
vim mi-vpn.conf

# 3. Establecer permisos seguros
chmod 600 mi-vpn.conf

# 4. Importar
sudo ./wireguard-manager.sh import ./mi-vpn.conf
```

### Información que necesitas para el archivo .conf:

1. **Tu clave privada** (genera con: `wg genkey`)
2. **Tu dirección IP en la VPN** (ejemplo: 10.0.0.2/24)
3. **Clave pública del servidor VPN**
4. **Dirección del servidor** (ejemplo: vpn.ejemplo.com:51820)

## ⚙️ Configuración Avanzada

### Deshabilitar autoconexión (recomendado)
```bash
sudo ./wireguard-manager.sh autoconnect disable
```

Por defecto, la autoconexión ya está deshabilitada para mayor control.

### Habilitar autoconexión (VPN siempre activa)
```bash
sudo ./wireguard-manager.sh autoconnect enable
```

La VPN se conectará automáticamente al iniciar el sistema.

## ❓ Problemas Comunes

### "nmcli command not found"
```bash
# Ubuntu/Debian
sudo apt-get install network-manager

# Fedora/RHEL
sudo dnf install NetworkManager
```

### "Connection already exists"
El script eliminará automáticamente la conexión existente al importar una nueva.

### La VPN no se conecta
```bash
# Verificar logs
sudo journalctl -u NetworkManager -f

# Verificar estado de NetworkManager
sudo systemctl status NetworkManager
```

## 🔒 Seguridad

- ✅ Los archivos `.conf` deben tener permisos `600` (solo lectura/escritura para el propietario)
- ✅ Nunca compartas tu clave privada
- ✅ La autoconexión está deshabilitada por defecto
- ✅ El script verifica permisos de root antes de realizar cambios

## 📚 Más Información

Para documentación completa, consulta: **README-WIREGUARD.md**

## 🆘 Obtener Ayuda

```bash
./wireguard-manager.sh help
```

---

**¿Tienes preguntas?** Abre un issue en: https://github.com/crowpor/repo_prueba_mastery/issues
