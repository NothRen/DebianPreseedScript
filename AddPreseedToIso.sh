#!/bin/sh

# Tableau qui contient les packages nécessaires pour l'éxecution du script
needed_packages=("xorriso" "genisoimage")


#Fonction qui vérifie si les packages nécessaires sont présent
check_needed_packages(){
	local package_missing=0
	
	for package in ${needed_packages[@]}
	do
		if ! dpkg -s $package &> /dev/null ; then
			echo "Le package apt \"$package\" est requis."
			package_missing=1
		fi
	done
	
	if [[ ! $package_missing -eq 0 ]];then
		exit
	fi
}


# On met les arguments dans des variables pour faciliter la lisibilité
preseed_file=$1
iso_file=$2
output=$3

# On vérifie si il y a bien au moins 2 arguments
if [[ $# < 2 ]]; then
	echo "Au moins 2 arguments sont nécessaire : le chemin vers le fichier preseed(.cfg) en premier et le chemin vers le ficher iso(.iso) en second. On peut rajouter le chemin d'ouput de l'iso modifier en troisième"
	exit
fi

# On vérifie si le premier argument est bien un fichier .cfg
if [[ $preseed_file != *.cfg ]]; then
	echo "Le premier argument doit être un fichier preseed avec .cfg comme extension"
	exit
fi

# On vérifie si le fichier preseed existe
if [[ ! -f $preseed_file ]]; then
	echo "Le fichier preseed n'existe pas"
	exit
fi

# On vérifie si le second argument est bien un fichier .iso
if [[ $iso_file != *.iso ]]; then
	echo "Le second argument doit être un fichier iso avec .iso comme extension"
	exit
fi

# On vérifie si le fichier iso existe
if [[ ! -f $iso_file ]]; then
	echo "Le fichier iso n'existe pas"
	exit
fi

# Si il n'y a pas de troisième arguments (pour le chemin de sortie), on dit que le chemin de sortie et le dossier actuel
if [[ -z $output ]];then
	output=$PWD
fi

check_needed_packages


echo "fini"




