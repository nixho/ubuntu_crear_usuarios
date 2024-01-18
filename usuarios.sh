#!/bin/bash

# Author: Israel Arizmendi

# Colors
endColour="\033[0m\e[0m"
Black="\033[0;30m"        # Black
Red="\033[0;31m"          # Red
Green="\033[0;32m"        # Green
Yellow="\033[0;33m"       # Yellow
Blue="\033[0;34m"         # Blue
Purple="\033[0;35m"       # Purple
Cyan="\033[0;36m"         # Cyan
White="\033[0;37m"        # White
Gray="\033[0;1m"        # White

trap ctrl_c INT

function ctrl_c(){
    echo "\nSalimos :D\n"
    tput cnorm
    exit 0
}

# Funciones

# Comprobar si el usuario existe
user_exists() {
  local usuario=$1
  if id "$usuario" &>/dev/null; then
	return 0
  else
    return 1
  fi
}

# Comprobar si el grupo existe
grupo_existe() {
  local grupo=$1
  if grep -q "^$grupo:" /etc/group; then
    return 0  
  else
    return 1  
  fi
}

# ayuda del script
function ayuda(){
    echo -e "\n${Yellow}[*]${endColour}${grayColour} Crear usario${endColour}"
    echo -e "\n\t${Yellow}Utiliza las opcciones para crear el usuario ${endColour}"
    echo -e "\t${Yellow}./script.sh -u usuario -p password -g grupo -a 1 ${endColour}"
	echo -e "\n\t${Purple}u)${endColour}${Yellow} Nombre del usuario ${endColour}"
	echo -e "\t${Purple}p)${endColour}${Yellow} Contraseña del usuario ${endColour}"
	echo -e "\t${Purple}g)${endColour}${Yellow} Grupo del Usuario${endColour}"
    echo -e "\t${Purple}a)${endColour}${Yellow} Es administrador ${endColour}\n"
	# exit 0
    return 0
}


# Main
declare -i parameter_counter=0; while getopts ":u:p:g:a:" arg; do
    case $arg in
        u) u=$OPTARG; let parameter_counter+=1 ;;
        p) p=$OPTARG; let parameter_counter+=1 ;;
        g) g=$OPTARG; let parameter_counter+=1 ;;
        a) a=$OPTARG; let parameter_counter+=1 ;;
    esac
done

if (( $parameter_counter < 3 || $parameter_counter > 5)); then
    ayuda
else
	if [ "$(id -u)" == "0" ]; then
		if ! user_exists "$u"; then
			# crear grupo si no existe
			if ! grupo_existe "$g"; then
				echo -e "\n${Yellow}El grupo no existe, se creará el grupo ${g} ${endColour}\n"
				groupadd "$g"
			fi

			# Crear el usuario
			echo -e "\n${Yellow} registrando al usuario ${u} ${endColour}\n"
			adduser --force-badname --gecos "" --disabled-password --ingroup "$g" "$u"

			# Establecer la contraseña para el usuario
			echo "$u:$p" | chpasswd
			# Agregar el usuario al grupo si es administrador
			if [ "$a" = true ]; then
				usermod -aG sudo "$u"
			fi

			echo -e "\n${Yellow} registrando al usuario ${u} ${endColour}\n"
			exit 0
		else
			echo -e "\n${Red}El usuario ya existe ${u}${endColour}\n"
			exit 0
		fi
		tput cnorm; 
		exit 0
	else
		echo -e "\n${Red}No eres root ${endColour}\n"
		exit 0
	fi
fi


 