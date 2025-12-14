#!/bin/bash

#puedes añadir rutas adicionales en la seccion 2 y en la seccion 1 y poner las rutas que quieres que busque software

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="$0"
export DescripcionDelScript="Script de gestion y configuracion de tu servidor sshd."
export Correo="scripts@mbbsistemas.com"
export Web="https://repositorio.mbbsistemas.es"
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="configurar_sshd.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/configurar_sshd" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [which]="which"
        [nano]="nano"
        [curl]="curl"
        [git]="git"
        [diff]="diff"
        [ping]="ping"
        [ssh]="ssh"
)

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
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} ($NombreScript)"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} ($DescripcionDelScript)"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} (Correo $Correo) (Web $Web)${borra_colores}"
echo ""
}


actualizar_script(){
    # actualizar el script
    #para que esta funcion funcione necesita:
    #   conexion a internet
    #   la paleta de colores
    #   software: git diff

    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1

    diff $ruta_ejecucion/$NombreScriptActualizar /tmp/comprobar/$NombreScriptActualizar >/dev/null 2>&1


    if [ $? = 0 ]
    then
        #esta actualizado, solo lo comprueba
        echo ""
        echo -e "${verde} El script${borra_colores} $0 ${verde}esta actualizado.${borra_colores}"
        echo ""
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
        actualizado="SI"
        sleep 2
    else
        #hay que actualizar, comprueba y actualiza
        echo ""
        echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
        echo -e "${verde} Se procede a su actualizacion automatica.${borra_colores}"
        sleep 3
        cp -r /tmp/comprobar/* $ruta_ejecucion
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
        echo ""
        echo -e "${amarillo} El script se ha actualizado, es necesario cargarlo de nuevo.${borra_colores}"
        echo ""
        sleep 2
        exit
    fi
}


software_necesario(){
#funcion software necesario
#para que funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: which

echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
#which git diff ping figlet xdotool wmctrl nano fzf
#########software="which git diff ping figlet nano gdebi curl konsole" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
for comando in "${!requeridos[@]}"; do
        which $comando &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                clear
                echo ""
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}sudo apt install ${requeridos[$comando]}${amarillo})${borra_colores}"
                echo -e ""
                echo -e " ${rojo}No se puede ejecutar el script sin el software necesario.${borra_colores}"
                echo ""; read p
                echo ""
                exit 1
            else
                echo " Instalando ${requeridos[$comando]}. Intento $contador/3."
                sudo apt install ${requeridos[$comando]} -y &>/dev/null
                let "contador=contador+1"
                which $comando &>/dev/null
                sino=$?
            fi
        done
        echo -e " [${verde}ok${borra_colores}] $comando (${requeridos[$comando]})."; software="SI"
    done

    echo ""
    echo -e "${azul} Todo el software ${verde}OK${borra_colores}"
    sleep 2
}


conexion(){
#funcion de comprobar conexion a internet
#para que funciones necesita:
#   conexion ainternet
#   la paleta de colores
#   software: ping

if ping -c1 google.com &>/dev/null
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

#logica de arranque
#variables de resultado $conexion $software $actualizado
#funciones actualizar_script, conexion, software_necesario

#logica para ejecutar o no ejecutar
#comprobado conexcion
#    si=actualizar_script
#        si=software_necesario
#            si=ejecuta, poner variables a sii todo
#            no=Ya sale el solo desde la funcion
#        no=software_necesario
#            si=ejecuta, variables software="SI", conexion="SI", actualizado="No se ha podiso comprobar actualizacion de script"
#            no=Ya sale solo desde la funcion
#
#    no=software_necesario
#        si=ejecuta, variables software="SI", conexion="NO", actualizado="No se ha podiso comprobar actualizacion de script"
#        no=Ya sale solo desde la funcion


clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    actualizar_script
    if [ $actualizado = "SI" ]; then
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="SI"
            #bash $ruta_ejecucion/ #PON LA RUTA
        else
            echo ""
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
check_ssh_status() {
    echo -e "${azul} Comprobando el estado del servidor SSH${borra_colores}"

    # 1️⃣ Detectar nombre del servicio
    local service_name=""
    if systemctl list-unit-files | grep -q '^ssh\.service'; then
        service_name="ssh"
    elif systemctl list-unit-files | grep -q '^sshd\.service'; then
        service_name="sshd"
    else
        echo -e "${rojo} No se encontró ningún servicio SSH registrado en systemd${borra_colores}"
        echo ""
        return 2
    fi

    # 2️⃣ Comprobar si está en ejecución
    if systemctl is-active --quiet "$service_name"; then
        echo -e " - Ejecucion del servicio${azul} $service_name${verde} OK${borra_colores}"
    else
        echo -e " - Ejecucion del servicio${azul} $service_name ${amarillo}KO${borra_colores}"
    fi

    # 3️⃣ Comprobar si está habilitado al arranque
    if systemctl is-enabled --quiet "$service_name"; then
        echo -e " - Servicio habilitado en el arranque${azul} $service_name ${verde}OK${borra_colores}"
    else
        echo -e " - Servicio habilitado en el arranque${azul} $service_name ${amarillo}KO${borra_colores}"
    fi

    # 4️⃣ Detectar el puerto configurado (en /etc/ssh/sshd_config)
    local ssh_port
    if [ -f /etc/ssh/sshd_config ]; then
        ssh_port=$(grep -E '^Port ' /etc/ssh/sshd_config | awk '{print $2}' | tail -n 1)
        # Si no hay línea Port, usar el valor por defecto (22)
        if [ -z "$ssh_port" ]; then
            ssh_port=22
        fi
        echo -e " - El servidor SSH usa el puerto:${azul} $ssh_port${borra_colores}"
    else
        echo -e "${rojo} No se encontró el archivo de configuración${borra_colores} /etc/ssh/sshd_config"
    fi

    # 5️⃣ Verificar si el puerto está escuchando
    if ss -tlnp 2>/dev/null | grep -q ":$ssh_port "; then
        echo -e " - El puerto${verde} $ssh_port ${borra_colores}está escuchando conexiones SSH"
    else
        echo -e "${amarillo} - El puerto${borra_colores} $ssh_port ${amarillo}no está escuchando (el servicio puede estar detenido o bloqueado por firewall)${borra_colores}"
    fi

    echo ""
}


# Función para activar la autenticación por contraseña
activar_password() {
    sudo sed -i '/PasswordAuthentication/ c\PasswordAuthentication yes' "$ssh_config"
    sudo service ssh restart
    echo ""
    echo -e "${verde} La autenticación por contraseña${borra_colores} ACTIVADO."
    echo ""; sleep 1
    return
}

# Función para desactivar la autenticación por contraseña
desactivar_password() {
    sudo sed -i '/PasswordAuthentication/ c\PasswordAuthentication no' "$ssh_config"
    sudo service ssh restart
    echo "" 
    echo -e "${verde} La autenticación por contraseña${borra_colores} DESACTIVADO."
    echo ""; sleep 1
    return
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

echo ""
echo -e "${verde} Puerto SSH cambiado a${borra_colores} $nuevo_puerto ${verde}en${borra_colores} $conf"; sleep 1

# Reiniciar el servicio SSH
echo ""
echo -e "${azul} Reiniciando el servicio SSH...${borra_colores}"; sleep 2
sudo systemctl restart sshd

# Verificar si el servicio se reinició correctamente
if systemctl is-active --quiet sshd; then
  echo ""
  echo -e "${verde} El servidor SSH ahora escucha en el puerto${borra_colores} $nuevo_puerto."; sleep 1
else
  echo ""
  echo -e "${rojo} Error al reiniciar el servicio SSH. Revisa la configuración manualmente.${borra_colores}"; sleep 2
  return
fi

}

# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"

# Menú de opciones
while :
do
clear
menu_info

# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"

echo ""
check_ssh_status

echo -e "${azul} --- MENU DE OPCIONES ---${borra_colores}"
echo ""
echo -e "${azul}  1. ${borra_colores}Activar la autenticación por contraseña."
echo -e "${azul}  2. ${borra_colores}Desactivar la autenticación por contraseña."
echo -e "${azul}  3. ${borra_colores}Editar el fichero de configuracion."
echo -e "${azul}  4. ${borra_colores}Cambiar puerto de escucha del ssh."
echo -e "${azul}  5. ${borra_colores}Activar reenvío (forwarding) del entorno gráfico."
echo -e "${azul}  6. ${borra_colores}Desactivar reenvío (forwarding) del entorno gráfico"
echo -e "${azul}  7. ${borra_colores}Activar demonio del servidor ssh."
echo -e "${azul}  8. ${borra_colores}Desactivar demonio del servidor ssh."
echo ""
echo -e "${azul} 99. ${borra_colores}Salir."
echo ""

read -p " Seleciona opcion del menu -> " opcion

case $opcion in
    1)
        activar_password
        ;;
    2)
        desactivar_password
        ;;
    
    3)
        sudo nano $ssh_config
        ;;

    4)
        cambiar_puerto_escucha
        ;;

    5)
        activar_x11
        ;;

    6)
        desactivar_x11
        ;;

    7)
        sudo systemctl enable ssh
        echo ""; echo -e "${verde} Demonio servidor ssh activado.${borra_colores}"; sleep 2
        ;;

    8)
        sudo systemctl disable ssh
        echo ""; echo -e "${verde} Demonio servidor ssh desactivado.${borra_colores}"; sleep 2
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
