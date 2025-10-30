#!/bin/bash

#colores
#ejemplo: echo -e "${verde} La opcion (-e) es para que pille el color.${borra_colores}"

rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores   git diff xdotool which

software_necesario(){
echo ""
echo -e " Comprobando el software necesario."
echo ""
software="which git diff ping figlet xdotool wmctrl" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
for paquete in $software
do
which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa llamado programa
sino=$? #recojemos el 0 o 1 del resultado de which
contador="1" #ponemos la variable contador a 1
    while [ $sino -gt 0 ] #entra en el bicle si variable programa es 0, no lo ha encontrado which
    do
        if [ $contador = "4" ] || [ $conexion = "no" ] 2>/dev/null 1>/dev/null 0>/dev/null #si el contador es 4 entre en then y sino en else
        then #si entra en then es porque el contador es igual a 4 y no ha podido instalar o no hay conexion a internet
            clear
            echo ""
            echo -e " ${amarillo}NO se ha podido instalar ${rojo}$paquete${amarillo}.${borra_colores}"
            echo -e " ${amarillo}Intentelo usted con la orden: (${borra_colores}sudo apt install $paquete ${amarillo})${borra_colores}"
            echo -e ""
            echo -e " ${rojo}No se puede ejecutar el script sin el software necesario.${borra_colores}"
            echo ""; read p
            echo ""
            exit
        else #intenta instalar
            echo " Instalando $paquete. Intento $contador/3."
            sudo apt install $paquete -y 2>/dev/null 1>/dev/null 0>/dev/null
            let "contador=contador+1" #incrementa la variable contador en 1
            which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa en tu sistema
            sino=$? ##recojemos el 0 o 1 del resultado de which
        fi
    done
echo -e " [${verde}ok${borra_colores}] $paquete."
software="SI"
done
}

actualizar_script(){
archivo_local="configurar_sshd.sh" # Nombre del archivo local
ruta_repositorio="https://github.com/sukigsx/configurar_sshd" #ruta del repositorio para actualizar y clonar con git clone

# Obtener la ruta del script
descarga=$(dirname "$(readlink -f "$0")")
git clone $ruta_repositorio /tmp/comprobar >/dev/null 2>&1

diff $descarga/$archivo_local /tmp/comprobar/$archivo_local >/dev/null 2>&1


if [ $? = 0 ]
then
    #esta actualizado, solo lo comprueba
    echo ""
    echo -e "${verde} El script${borra_colores} $0 ${verde}esta actualizado.${borra_colores}"
    echo ""
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    actualizado="SI"
else
    #hay que actualizar, comprueba y actualiza
    echo ""
    echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
    echo -e "${verde} Se procede a su actualizacion automatica.${borra_colores}"
    sleep 3
    mv /tmp/comprobar/$archivo_local $descarga
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${amarillo} El script se ha actualizado, es necesario cargarlo de nuevo.${borra_colores}"
    echo -e ""
    read -p " Pulsa una tecla para continuar." pause
    exit
fi
}

conexion(){
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

# EMPIEZA LO GORDO
check_ssh_status() {
    echo -e "${azul} Comprobando el estado del servidor SSH${borra_colores}"
    echo ""

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



clear
echo ""
conexion
echo ""
if [ $conexion = "SI" ]
then
    #si hay internet
    software_necesario
    actualizar_script
else
    #no hay internet
    software_necesario
fi
sleep 2

# Función para activar la autenticación por contraseña
activar_password() {
    sudo sed -i '/PasswordAuthentication/ c\PasswordAuthentication yes' "$ssh_config"
    sudo service ssh restart
    echo ""
    echo -e "${verde} La autenticación por contraseña se ha activado.${borra_colores}"
    echo "" 
    exit
}

# Función para desactivar la autenticación por contraseña
desactivar_password() {
    sudo sed -i '/PasswordAuthentication/ c\PasswordAuthentication no' "$ssh_config"
    sudo service ssh restart
    echo "" 
    echo -e "${verde} La autenticación por contraseña se ha desactivado.${borra_colores}"
    echo ""
    exit
}

#funcion cambiar puerto de escucha
cambiar_puerto_escucha(){
# Pedir el nuevo puerto
read -p " Introduce el nuevo puerto SSH (1024-65535): " nuevo_puerto

# Validar que sea un número válido
if ! [[ "$nuevo_puerto" =~ ^[0-9]+$ ]] || [ "$nuevo_puerto" -lt 1024 ] || [ "$nuevo_puerto" -gt 65535 ]; then
  echo -e "${rojo} Puerto inválido. Debe ser un número entre 1024 y 65535.${borra_colores}"; sleep 2
  return
fi

# Ruta del archivo de configuración de SSH
conf="/etc/ssh/sshd_config"

# Si ya existe una línea 'Port', reemplazarla; si no, añadir al final
if grep -q "^#\?Port " "$conf"; then
  sed -i "s/^#\?Port .*/Port $nuevo_puerto/" "$conf"
else
  echo "Port $nuevo_puerto" >> "$conf"
fi

echo -e "${verde} Puerto SSH cambiado a${borra_colores} $nuevo_puerto ${verde}en${borra_colores} $conf"; sleep 2

# Reiniciar el servicio SSH
echo -e "${azul} Reiniciando el servicio SSH...${borra_colores}"; sleep 2
systemctl restart sshd

# Verificar si el servicio se reinició correctamente
if systemctl is-active --quiet sshd; then
  echo -e "${verde} El servidor SSH ahora escucha en el puerto${borra_colores} $nuevo_puerto."; sleep 2
else
  echo -e "${rojo} Error al reiniciar el servicio SSH. Revisa la configuración manualmente.${borra_colores}"; sleep 2
  break
fi

}



# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"

# Menú de opciones
while :
do


# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"

clear

echo -e "${rosa}"; figlet -c sukigsx; echo -e "${borra_colores}"
echo ""
echo -e "${verde} Diseñado por sukigsx / Contacto:   scripts@mbbsistemas.es${borra_colores}"
echo -e "${verde}                                    https://repositorio.mbbsistemas.es${borra_colores}"
echo ""
echo -e "${verde} Nombre del script < $0 > Configuracion por menus de las principales opciones de tu servidor ssh.  ${borra_colores}"
echo ""
echo -e "${verde} Configurado =${borra_colores} $configurar${verde}. Conexion a internet =${borra_colores} $conexion${verde}. Software necesario =${borra_colores} $software${verde}. Script actualizado =${borra_colores} $actualizado."
echo ""
check_ssh_status
echo -e "${azul}  1. ${borra_colores}Activar la autenticación por contraseña."
echo -e "${azul}  2. ${borra_colores}Desactivar la autenticación por contraseña."
echo ""
echo -e "${azul}  3. ${borra_colores}Editar el fichero de configuracion."
echo -e "${azul}  4. ${borra_colores}Cambiar puerto de escucha del ssh."
echo -e "${azul}  5. ${borra_colores}Opcion vacia de momento."
echo -e "${azul}  6. ${borra_colores}Opcion vacia de momento."
echo -e "${azul}  7. ${borra_colores}Opcion vacia de momento."
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
   99)
        echo ""
	exit;;

    *)
        echo ""
	echo -e "${rojo} Opción no válida. (Selecciona 1,2 o 99).${borra_colores}"
	sleep 3
        ;;
esac
done
