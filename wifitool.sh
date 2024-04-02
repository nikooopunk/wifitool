#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Funciones
function menu(){
    echo -e "\tPara conectarse a una red usa al tiempo:\n\t-r \"Red Wifi\" -p \"Contraseña\""
    echo -e "\n\t-g 	 Ver redes Guardadas"
    echo -e "\t-w 	 Ver contraseña wifi de la red solicitada"
    echo -e "\t-l 	 Listar redes wifi disponibles\n"
}

function verRedesDisponibles(){
    echo -e "\n${greenColour}[+]${endColour} ${blueColor}Redes wifi disponibles:${endColour}"
    echo -e "\n${turquoiseColour}$(nmcli device wifi list | grep -v '*' | awk -F '  ' '{print $6}' | column)${endColour}"
}

function conectarseWifi(){
    redWifi="$1"
    clave="$2"

    echo -e "Conetcando a la red wifi $redWifi"
    nmcli device wifi connect $redWifi password $clave
}

function redesGuardadas(){
	nmcli connection show | awk -F '  ' '{print $1}' | grep -v "NAME" | column
}

function mostrarPassword(){
	#se necesitan permisos de root para esta funcion
	user="$(whoami)"

	if [ "$user" == "root" ]; then
		passWifi="$(sudo cat /etc/NetworkManager/system-connections/$wifiPass | grep "psk=" | awk -F 'psk=' '{print $2}')"
		echo -e "$passWifi"
	else
		echo -e "se necesitan permisos de root para ejecutar esta funcion"
	fi
}
# Indicadores
declare -i parameter_counter=0

#Indicadores combinados
declare -i comb_r=0
declare -i comb_p=0

#Menu
while getopts "lr:p:gw:" arg; do
    case $arg in
        l) parameter_counter+=1;;
        r) redWifi="$OPTARG"; comb_r=1;;
        p) clave="$OPTARG"; comb_p=1;;
        g) parameter_counter+=2;;
        w) wifiPass="$OPTARG"; parameter_counter+=3;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    verRedesDisponibles
elif [ $comb_r -eq 1 ] && [ $comb_p -eq 1 ]; then
	conectarseWifi "$redWifi" "$clave"
elif [ $parameter_counter -eq 2 ]; then
	redesGuardadas
elif [ $parameter_counter -eq 3 ]; then
	mostrarPassword "$wifiPass"
else
    menu
fi
