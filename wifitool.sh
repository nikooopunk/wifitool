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
    echo -e "${yellowColour}[+]${endColour}${blueColour}Para conectarse a una red usa al tiempo:\n\t${yellowColour}-r${endColour} ${blueColour}\"Red Wifi\" ${yellowColour}-p${endColour} ${blueColour}\"Contraseña\"${endColour}"
    echo -e "${yellowColour}[+]${endColour}${blueColour}Opciones principales${endColour}"
    echo -e "\t${yellowColour}-g${endColour} 	 ${blueColour}Ver redes Guardadas${endColour}"
    echo -e "\t${yellowColour}-w${endColour} 	 ${blueColour}Ver contraseña wifi de la red solicitada${endColour}${endColour}"
    echo -e "\t${yellowColour}-l${endColour} 	 ${blueColour}Listar redes wifi disponibles${endColour}"
}

function verRedesDisponibles(){
    echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Redes wifi disponibles:${endColour}"
    echo -e "\n${turquoiseColour}$(nmcli device wifi list | grep -v '*' | awk -F '  ' '{print $6}' | column)${endColour}"
}

function conectarseWifi(){
    redWifi="$1"
    clave="$2"

    echo -e "${yellowColour}[+]${endColour}${blueColour}Conetcando a la red wifi${endColour} ${yellowColour}$redWifi${endColour}"
    echo -e "${blueColour}$(nmcli device wifi connect $redWifi password $clave)${endColour}"
}

function redesGuardadas(){
	echo -e "${yellowColour}[+]${endColour} ${blueColour}Listando redes wifi guardadas${endColour}"
	echo -e "${turquoiseColour}$(nmcli connection show | awk -F '  ' '{print $1}' | grep -v "NAME" | column)${endColour}"
}

function mostrarPassword(){
	#se necesitan permisos de root para esta funcion
	user="$(whoami)"

	if [ "$user" == "root" ]; then
		passWifi="$(sudo cat /etc/NetworkManager/system-connections/$wifiPass &>/dev/null | grep "psk=" | awk -F 'psk=' '{print $2}')"
		passWifiForce="$(sudo cat /etc/NetworkManager/system-connections/$wifiPass.nmconnection &>/dev/null | grep "psk=" | awk -F 'psk=' '{print $2}')"

		if [ ! "$(sudo cat /etc/NetworkManager/system-connections/$wifiPass &>/dev/null || echo $?)" == 1 ]; then
			echo -e "${yellowColour}[!]${endColour} ${blueColour}La contraseña de la red ${yellowColour}$wifiPass${endColour} ${blueColour}es:${endColour} ${yellowColour}$(sudo cat /etc/NetworkManager/system-connections/Perez_Guazo | grep "psk=" | awk -F 'psk=' '{print $2}')${endColour}"
		else
			echo -e "${yellowColour}[+]${endColour} ${blueColour}La contraseña de la red ${yellowColour}$wifiPass${endColour} ${blueColour}es:${endColour} ${yellowColour}$(sudo cat /etc/NetworkManager/system-connections/$wifiPass.nmconnection | grep 'psk=' | awk -F 'psk=' '{print $2}')${endColour}"
		fi
		#echo -e "$wifiPass"
	else
		echo -e "${redColour}[!]${endColour} ${blueColour}Se necesitan permisos de root para ejecutar esta funcion.${endColour}"
	fi
}
# Indicadores
declare -i parameter_counter=0

#Indicadores combinados
declare -i comb_r=0
declare -i comb_p=0

#Menu
while getopts "lr:p:gw:h" arg; do
    case $arg in
        l) parameter_counter+=1;;
        r) redWifi="$OPTARG"; comb_r=1;;
        p) clave="$OPTARG"; comb_p=1;;
        g) parameter_counter+=2;;
        w) wifiPass="$OPTARG"; parameter_counter+=3;;
        h) ;;
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
