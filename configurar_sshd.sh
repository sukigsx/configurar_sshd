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

# Ruta al archivo de configuración de SSH
ssh_config="/etc/ssh/sshd_config"

# Menú de opciones
while :
do

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
echo -e "${azul}  1. Activar la autenticación por contraseña.${borra_colores}"
echo -e "${azul}  2. Desactivar la autenticación por contraseña.${borra_colores}"
echo ""
echo -e "${azul}  3. Opcion vacia de momentoooooooo.${borra_colores}"
echo -e "${azul}  4. Opcion vacia de momento.${borra_colores}"
echo -e "${azul}  5. Opcion vacia de momento.${borra_colores}"
echo -e "${azul}  6. Opcion vacia de momento.${borra_colores}"
echo -e "${azul}  7. Opcion vacia de momento.${borra_colores}"
echo ""
echo -e "${azul} 99. Salir.${borra_colores}"
echo ""
read -p " Seleciona opcion del menu -> " opcion

case $opcion in
    1)
        activar_password
        ;;
    2)
        desactivar_password
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
