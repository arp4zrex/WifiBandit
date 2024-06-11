# WifiBandit
WiFiBandit es un script diseñado para realizar pruebas de penetración en redes WiFi con el objetivo de evaluar su seguridad y detectar posibles vulnerabilidades. El script proporciona una interfaz interactiva para configurar la tarjeta de red, seleccionar el modo de ataque y realizar los ataques correspondientes.

# Uso
Clona este repositorio en tu máquina local:
git clone https://github.com/arp4zrex/WifiBandit.git
cd wifibandit
chmod +x wifibandit.sh
./wifibandit.sh

# Requisitos
aircrack-ng: Utilidad para auditoría de seguridad inalámbrica.
macchanger: Herramienta para cambiar la dirección MAC de una interfaz de red.
hostapd: Software de punto de acceso Wi-Fi.
iwconfig: Utilidad para configurar parámetros de una interfaz de red inalámbrica.
tcpdump: Herramienta de captura y análisis de paquetes de red.
xterm: Emulador de terminal para mostrar ventanas de terminal.
hashcat: Herramienta de recuperación de contraseñas.
hcxdumptool: Herramienta para capturar PMKID de redes Wi-Fi.

# Tipos de Ataques

# Handshake
Este modo de ataque se utiliza para capturar el handshake de autenticación entre un dispositivo cliente y un punto de acceso Wi-Fi. Una vez capturado el handshake, se pueden realizar ataques de fuerza bruta para descifrar la contraseña de la red.
Este ataque implica la captura de paquetes de autenticación entre un dispositivo cliente y un punto de acceso. Una vez capturado el handshake, se puede utilizar un diccionario de contraseñas para intentar descifrar la contraseña de la red.
El script utiliza herramientas como airodump-ng para escanear las redes WiFi disponibles y capturar el handshake de autenticación.
Una vez capturado el handshake, se puede utilizar la herramienta aircrack-ng junto con un diccionario de contraseñas para intentar descifrar la contraseña de la red.
El tiempo necesario para capturar un handshake puede variar según la actividad de la red y el número de dispositivos conectados.

# PKMID
El ataque PKMID es un ataque sin cliente que aprovecha una vulnerabilidad en el estándar de autenticación WPA/WPA2 para capturar hashes PMKID. Estos hashes pueden ser posteriormente utilizados en un ataque de fuerza bruta para obtener la contraseña de la red.
En este ataque, se capturan los hashes PMKID necesarios para realizar un ataque de fuerza bruta contra la contraseña de la red. Este ataque puede realizarse sin necesidad de clientes asociados a la red, lo que lo hace especialmente sigiloso.
Este ataque aprovecha una vulnerabilidad en el protocolo de autenticación de las redes WiFi WPA/WPA2.
El script utiliza la herramienta hcxdumptool para capturar el PMKID, que es un hash derivado de la contraseña de la red y la dirección MAC del punto de acceso.
Una vez capturado el PMKID, se puede intentar descifrar la contraseña utilizando herramientas como hashcat junto con un diccionario de contraseñas.

