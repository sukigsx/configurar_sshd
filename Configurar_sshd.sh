#!/usr/bin/env bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="ppsskjhlkjhlkjh"
export DescripcionDelScript="PRUEBA DE MEJORA"
export Correo="scripts@mbbsistemas.es"
export Web="https://repositorio.mbbsistemas.es"
export version="1.11111"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="Sin comprobar"
paqueteria="No detectada"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="Configurar_sshd.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/configurar_sshd" #contiene la direccion de github para actualizar el script
nombre_carpeta_repositorio="Configurar_sshd.sh" #poner el nombre de la carpeta cuando se clona el repo para poder eliminarla

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        #requeridos para poder actualizar
        [git]="git"
        [diff]="diff"
        [sudo]="sudo"
        [ping]="ping"
        [xdg-user-dir]="xdg-user-dirs"

        #requeridos para el script en si
        [ssh]="ssh"
        [nano]="nano"
        [which]="which"
        [systemctl]="systemd"
        [ssh]="ssh"
        [sed]="sed"
    )
###########################
## FUNCIONES PRINCIPALES ##
###########################
#colores
rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores

#toma el control al pulsar control + c
trap ctrl_c INT
function ctrl_c()
{
clear
echo ""
echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
echo ""
sleep 1
exit
}

menu_info(){
# muestra el menu de sukigsx
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} $NombreScript"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} $DescripcionDelScript"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e "${rosa}                                    ${azul}   Sistema paqueteria =${borra_colores} $paqueteria"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} ( Correo${rosa} $Correo${borra_colores} ) ( Web${rosa} $Web${borra_colores} )${borra_colores}"
echo ""
}

#comprobar si hay actualizaciones y que lo marque en el menu_info y tambien pregunta si quieres actualizar
comprobar_actualizaciones(){

    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1
    diff $ruta_ejecucion/$NombreScriptActualizar /tmp/comprobar/$NombreScriptActualizar >/dev/null 2>&1

    if [ $? = 0 ]
    then
        #esta actualizado, solo lo comprueba
        actualizado="SI"
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    else
        #hay que actualizar, comprueba y actualiza
        echo ""
        echo -e "${amarillo} Existe una actualizacion del script${borra_colores}"
        read -p " Quieres actualizar ? (S/n): " sino
        if [[ $sino == [sS] ]]; then
            actualizar_script
        else
            actualizado="NO"
        fi
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    fi
}

#funcion para actualizar el script
actualizar_script(){
    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1

    cp -r /tmp/comprobar/* $ruta_ejecucion
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${amarillo} Sera necesario ejecutarlo de nuevo.${borra_colores}"

    printf " Actualizando... "
    for i in {1..20}; do
        printf "#"
        sleep 0.1
    done
    printf " [ \e[32mOK\e[0m ]\n"

    echo ""
    sleep 1
    exit
}

#funcion para comprobar el software necesario
software_necesario(){
#funcion software necesario
#para que funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: which
paqueteria
echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
for comando in "${!requeridos[@]}"; do
        command -v $comando &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                clear
                menu_info
                echo -e " ${amarillo}NO se puede ejecutar el script sin los paquetes necesarios ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}$instalar${requeridos[$comando]}${amarillo})${borra_colores}"
                echo -e ""
                echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"
                for elemento in "${requeridos[@]}"; do
                    echo -e "     $elemento"
                done
                echo ""
                echo -e " ${rojo}No se puede ejecutar el script sin todo el software necesario.${borra_colores}"
                echo ""
                read -p " Pulsa una tecla para continuar" pulsa
                exit 1
            else
                echo -e "${amarillo} Se necesita instalar ${borra_colores}$comando${amarillo} para la ejecucion del script${borra_colores}"
                ### check_root
                echo " Instalando ${requeridos[$comando]}. Intento $contador/3."
                $instalar ${requeridos[$comando]} &>/dev/null
                let "contador=contador+1"
                command -v $comando &>/dev/null
                sino=$?
            fi
        done
        echo -e " [${verde}ok${borra_colores}] $comando (${requeridos[$comando]})."
    done

    echo ""
    echo -e "${azul} Todo el software ${verde}OK${borra_colores}"
    software="SI"
}

# Función que comprueba si se ejecuta como root
check_root() {
    #clear
    #menu_info
  if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "${amarillo} Se necesita privilegios de root ingresa la contraseña.${borra_colores}"

    # Pedir contraseña para sudo
    #echo -e ""

    # Validar contraseña mediante sudo -v (verifica sin ejecutar comando)
    if sudo -v; then
      echo ""
      echo -e "${verde} Autenticación correcta. Ejecutando como root...${borra_colores}"; sleep 2
      # Reejecuta el script como root
      #exec sudo "$0" "$@"
    else
      clear
      menu_info
      echo -e "${rojo} Contraseña incorrecta o acceso denegado. Saliendo del script.${borra_colores}"
      echo ""
      echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"
      for elemento in "${requeridos[@]}"; do
        echo -e "     $elemento"
      done
      echo ""
      echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
     echo ""; exit
    fi
  fi
}

#funcion de detectar sistema de paquetado para instalar
paqueteria(){
echo ""
echo -e "${azul} Detectando sistema de paquetería...${borra_colores}"
echo ""

if command -v apt >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: APT (Debian, Ubuntu, Mint, etc.)${borra_colores}"
    instalar="sudo apt install -y "
    paqueteria="apt"

elif command -v dnf >/dev/null 2>&1; then
    echo -e "${cerde} Sistema de paquetería detectado: DNF (Fedora, RHEL, Rocky, AlmaLinux)${borra_colores}"
    instalar="sudo dnf install -y "
    paqueteria="dnf"

elif command -v yum >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: YUM (CentOS, RHEL antiguos)${borra_colores}"
    instalar="sudo yum install -y "
    paqueteria="yum"

elif command -v pacman >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Pacman (Arch Linux, Manjaro)${borra_colores}"
    instalar="sudo pacman -S --noconfirm "
    paqueteria="pacman"

elif command -v zypper >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Zypper (openSUSE)${borra_colores}"
    instalar="sudo zypper install -y "
    paqueteria="zypper"

elif command -v apk >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: APK (Alpine Linux)${borra_colores}"
    instalar="sudo apk add --no-interactive "
    paqueteria="apk"

elif command -v emerge >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: Portage (Gentoo)${borra_colores}"
    instalar="sudo emerge -av "
    paqueteria="emerge"

else
    echo -e "${amarillo} No se pudo detectar un sistema de paquetería conocido.${borra_colores}"
    paqueteria="${rojo}Desconocido${borra_colores}"
fi
#sleep 2
}


#comprobar si se ejecuta en una terminal bash
terminal_bash() {

    shell_actual="$(ps -p $$ -o comm=)"

    if [ "$shell_actual" != "bash" ]; then
        echo -e "${amarillo} Este script ${rojo}NO${amarillo} se está ejecutando en Bash.${borra_colores}"
        echo -e "   Shell detectado: ${rojo}$shell_actual${borra_colores}"
        echo -e "   Puede ocasionar problemas ya que solo está pensado para bash."
        echo -e "   ${rojo}No${borra_colores} se procede con la instalación ni la ejecución."
        echo ""
        echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
        echo ""
        exit 1
    fi
}

conexion(){
#funcion de comprobar conexion a internet
#para que funciones necesita:
#   conexion ainternet
#   la paleta de colores
#   software: ping

if ping -c1 -W1 8.8.8.8 &>/dev/null
then
    conexion="SI"
    echo ""
    echo -e " Conexion a internet = ${verde}SI${borra_colores}"
else
    conexion="NO"
    echo ""
    echo -e " Conexion a internet = ${rojo}NO${borra_colores}"
fi
}

#logica de inicio
clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    comprobar_actualizaciones
    if [ $actualizado = "SI" ]; then
        terminal_bash
        software_necesario
        if [ "$software" = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="SI"
            #bash $ruta_ejecucion/ #PON LA RUTA
        else
            echo ""
        fi
    else
        terminal_bash
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="NOOOOO"
            #bash $ruta_ejecucion/ #PON LA RUTA
        else
            echo ""
        fi
    fi
else
    software_necesario
    if [ $software = "SI" ]; then
        export software="SI"
        export conexion="NO"
        export actualizado="No se ha podido comprobar la actualizacion del script"
        #bash $ruta_ejecucion/ #PON LA RUTA
    else
        echo ""
    fi
fi


# EMPIEZA LO GORDO


# Activar/desactivar el servicio
ssh_onoff(){
# Comprobar estado actual
    if systemctl is-active --quiet "$servicio"; then
        # Está activo → parar
        sudo systemctl stop "$servicio"
    else
        # Está parado → arrancar
        sudo systemctl start "$servicio"
    fi
    sudo systemctl restart $servicio
}

# Función para activar x11
activar_x11() {
    sudo sed -i '/X11Forwarding/ c\        X11Forwarding yes' "$ssh_config"
    sudo service ssh restart
    echo ""
    echo -e "${verde} Reenvío (forwarding) del entorno gráfico${borra_colores} ACTIVADO."

    # Reiniciar el servicio SSH
    echo ""
    echo -e "${azul} Reiniciando el servicio SSH...${borra_colores}"; sleep 2
    sudo systemctl restart sshd

    # Verificar si el servicio se reinició correctamente
    if systemctl is-active --quiet sshd; then
        echo ""
    else
        echo ""
        echo -e "${rojo} Error al reiniciar el servicio SSH. Revisa la configuración manualmente.${borra_colores}"; sleep 2
        return
    fi
}

# Función para desactivar x11
desactivar_x11() {
    sudo sed -i '/X11Forwarding/ c\        X11Forwarding no' "$ssh_config"
    sudo service ssh restart
    echo ""
    echo -e "${verde} Reenvío (forwarding) del entorno gráfico${borra_colores} DESACTIVADO."
    # Reiniciar el servicio SSH
    echo ""
    echo -e "${azul} Reiniciando el servicio SSH...${borra_colores}"; sleep 2
    sudo systemctl restart sshd

    # Verificar si el servicio se reinició correctamente
    if systemctl is-active --quiet sshd; then
        echo ""
    else
        echo ""
        echo -e "${rojo} Error al reiniciar el servicio SSH. Revisa la configuración manualmente.${borra_colores}"; sleep 2
        return
    fi
}

#funcion cambiar puerto de escucha
cambiar_puerto_escucha(){
# Pedir el nuevo puerto
echo ""
read -p " Introduce el nuevo puerto SSH (1-65535): " nuevo_puerto

# Validar que sea un número válido
if ! [[ "$nuevo_puerto" =~ ^[0-9]+$ ]] || [ "$nuevo_puerto" -lt 1 ] || [ "$nuevo_puerto" -gt 65535 ]; then
  echo ""
  echo -e "${rojo} Puerto inválido. Debe ser un número entre 1 y 65535.${borra_colores}"; sleep 2
  return
fi

# Ruta del archivo de configuración de SSH
conf="/etc/ssh/sshd_config"

# Si ya existe una línea 'Port', reemplazarla; si no, añadir al final
if grep -q "^#\?Port " "$conf"; then
  sudo sed -i "s/^#\?Port .*/Port $nuevo_puerto/" "$conf"
else
  echo ""
  echo "Port $nuevo_puerto" >> "$conf"
fi

sudo systemctl restart $servicio
}

comprobar_estados(){
    # Detectar nombre del servicio
    if systemctl list-units --type=service | grep -qE 'ssh\.service'; then
        servicio="ssh"
    elif systemctl list-units --type=service | grep -qE 'sshd\.service'; then
        servicio="sshd"
    else
        servicio="Desactivado"
        #return 1
    fi

    # Estado del servicio sshd enable o disable el demonio
    if systemctl is-enabled --quiet "$servicio"; then
        estado="Activado"
    else
        estado="Desactivado"
    fi

    # Puerto configurado
    puerto=$(grep -Ei '^\s*Port ' "$ssh_config" | awk '{print $2}' | tail -n1)
    puerto=${puerto:-22}

    # Estado de PasswordAuthentication
    estado_password=$(grep -Ei '^\s*#?\s*PasswordAuthentication' "$ssh_config" | tail -n1)
}

activar_desactivar_password() {
    # Obtener estado actual
    estado_actual=$(grep -Ei '^\s*#?\s*PasswordAuthentication' "$ssh_config" | tail -n1)

    if echo "$estado_actual" | grep -qi "yes"; then
        # Está activado → desactivar
        sudo sed -i 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication no/' "$ssh_config"
        sudo systemctl restart ssh
    else
        # Está desactivado → activar
        sudo sed -i 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$ssh_config"
        sudo systemctl restart ssh
    fi
}

# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"
check_root

# Menú de opciones
while :
do
clear
menu_info

# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"

echo ""
comprobar_estados
echo -e "${azul} --- MENU DE OPCIONES ---${borra_colores}"
echo ""
echo -e "${azul}  1. ${borra_colores}Activar/Desactivar servidor ssh. Estado = [${verde} $servicio ${borra_colores}]"
echo -e "${azul}  2. ${borra_colores}Activar/Desactivar demonio del servidor ssh. Estado = [ $estado ]"
echo -e "${azul}  3. ${borra_colores}Cambiar puerto de escucha del ssh. Estado = [${verde} $puerto ${borra_colores}]"
echo -e "${azul}  4. ${borra_colores}Activar/Desactivar reenvío (forwarding) del entorno gráfico"
echo -e "${azul}  5. ${borra_colores}Activar/desactivar la autenticación por contraseña. Estado = [${verde} $estado_password ${borra_colores}]"
echo -e "${azul}  6. ${borra_colores}Editar el fichero de configuracion."
echo ""
echo -e "${azul} 99. ${borra_colores}Salir."
echo ""

read -p " Seleciona opcion del menu -> " opcion

case $opcion in
    1)  #Activar/Desactivarvservidor ssh.
        ssh_onoff
        ;;
    2)  #Activar/Desactivar demonio del servidor ssh

        ;;
    
    3)  #cambiar puerto de escucha
        cambiar_puerto_escucha

        ;;

    4)  #Activar/Desactivar reenvío (forwarding) del entorno gráfico

        ;;

    5)  #Activar/desactivar la autenticación por contraseña.
        activar_desactivar_password
        ;;

    6)  #editar fichero configuracion
        sudo nano $ssh_config
        #desactivar_x11
        ;;

    7)
        sudo systemctl enable ssh > /dev/null 2>&1
        echo ""; echo -e "${verde} Demonio servidor ssh activado.${borra_colores}"; sleep 2
        ;;

    8)
        sudo systemctl disable ssh > /dev/null 2>&1
        echo ""; echo -e "${verde} Demonio servidor ssh desactivado.${borra_colores}"; sleep 2
        ;;

    9)
        sudo systemctl start ssh > /dev/null 2>&1
        echo ""; echo -e "${verde} Activado el servidor ssh.${borra_colores}"; sleep 2
        ;;
   10)
        sudo systemctl stop ssh > /dev/null 2>&1
        echo ""; echo -e "${verde} Desactivado el servidor ssh.${borra_colores}"; sleep 2
        ;;

   99)
        echo ""
        ctrl_c;;

    *)
        echo ""
        echo -e "${rojo} Opción no válida. (Selecciona 1,2 o 99).${borra_colores}"
        sleep 3
        ;;
esac
done
