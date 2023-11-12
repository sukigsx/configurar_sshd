# CONFIGURAR SSHD

Este script en Bash es para configurar opciones específicas del servidor SSH de una manera interactiva. A continuación, se proporciona una descripción detallada de su funcionamiento:

- Definición de colores:
Se definen variables que contienen códigos de color ANSI para utilizar en mensajes de salida.
Función software_necesario:

- Verifica la existencia de ciertos programas esenciales (git, diff, ping, figlet, xdotool, wmctrl) en el sistema.
Si algún programa no está instalado, intenta instalarlo utilizando apt.
Si no puede instalar un programa después de tres intentos, muestra un mensaje indicando que el script no puede ejecutarse sin el software necesario y termina.
Función actualizar_script:

- Comprueba si el script actual está actualizado con respecto a su versión en un repositorio de GitHub.
Si está actualizado, muestra un mensaje y continúa.
Si no está actualizado, descarga la versión más reciente del repositorio y reemplaza el script local.
Muestra un mensaje indicando que el script se ha actualizado y solicita al usuario que lo vuelva a cargar.

- Función conexion:
Realiza una prueba de ping a google.com para verificar si hay conexión a Internet.
Muestra un mensaje indicando si hay o no conexión.

- Parte principal del script:
Realiza la conexión a Internet y, si hay conexión, verifica e instala el software necesario.
Luego, verifica y actualiza el script si es necesario.
Después, presenta un menú interactivo al usuario con varias opciones relacionadas con la configuración del servidor SSH.
Las opciones del menú permiten activar o desactivar la autenticación por contraseña en el servidor SSH.
También muestra información sobre el estado de la configuración, la conexión a Internet, la instalación del software y la actualización del script.
El menú se ejecuta en un bucle hasta que el usuario elige salir (opción 99).

## SE IRAN COLOCANDO NUEVAS OPCIONES AL MENU

## Instalacion
ejecutar git clone https://github.com/sukigsx/configurar_sshd.git
luego ejecutar ./configurar_sshd.sh o bien bash configurar_sshd.sh

# ESPERO OS GUSTE.....
