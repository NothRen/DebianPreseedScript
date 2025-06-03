#!/bin/bash


needed_packages=("xorriso" "genisoimage") # Tableau qui contient les packages nécessaires pour l'éxecution du script
working_directory="./buildPressed/" # Dossier ou l'on va décompresser l'iso et faire les manipulations
complete_auto_install=0 # Flag pour savoir si on fait une auto installation complète ou non

# On met les arguments dans des variables pour faciliter la lisibilité
preseed_file=$1 # Le chemin vers le fichier preseed
preseed_file_name=$(basename $preseed_file) # Le nom du fichier preseed
iso_file=$2 # Le chemin vers le fichier iso
iso_file_name=$(basename $iso_file) # Le nom du fichier iso
output_file=$3 # Le chemin de sortie (optionnelle. Si il n'est pas précisé, on prend le dossier d'où le script est éxécuté)
output_file_name=${iso_file_name::-4}"_preseeded.iso" # Le nom que l'iso de sortie aura

#Fonction qui vérifie si les packages nécessaires sont présent
check_needed_packages(){
	local package_missing=0
	
	# On itère sur la liste des packages requis qui sont dans "needed_packages"
	for package in ${needed_packages[@]}
	do
		# Avec "dpkg -s $package" on cherche si le package est installé, puis on redirige l'output de la commande vers /dev/null avec &>
		if ! dpkg -s $package &> /dev/null ; then
			echo "Le package apt \"$package\" est requis."
			package_missing=1
		fi
	done
	
	# Si il manque un package ou plus on finit le programme
	if [[ ! $package_missing -eq 0 ]];then
		exit 1
	fi
}

# Fonction qui demande si il faut faire une auto installation complete
ask_for_auto_install(){
	# On demande (-n Fait que le curseur reste sur la ligne)
	echo -n "Voulez vous une auto installation complète, si oui vous ne pourrez plus installer l'iso manuellement ? (O/N) : "
	
	# On lit ce que l'utilisateur à écrit et on le met dans "answer"
	read answer
	
	# On vérifie si answer contient bien une réponse attendue, 
	# Si la réponse est oui : On met "complete_auto_install" à 1
	# Si la réponse est non : On met "complete_auto_install" à 0
	# Sinon on met un message d'erreur et on fini le program
	case "$answer" in
		oui | Oui | o | O | yes | Yes | y | Y ) complete_auto_install=1;;
		non | Non | n | N | no | No  ) complete_auto_install=0;;
		* ) echo "Veuillez répondre oui ou non";exit 1 ;;
	esac
}


clear_folder(){
	# On supprime le dossier de travail
	rm -rf $working_directory
}

# On vérifie si il y a bien au moins 2 arguments
if [[ $# < 2 ]]; then
	echo "Au moins 2 arguments sont nécessaire : le chemin vers le fichier preseed(.cfg) en premier et le chemin vers le ficher iso(.iso) en second. On peut rajouter le chemin d'ouput de l'iso modifier en troisième"
	exit 1
fi

# On vérifie si le premier argument est bien un fichier .cfg
if [[ $preseed_file != *.cfg ]]; then
	echo "Le premier argument doit être un fichier preseed avec .cfg comme extension"
	exit 1
fi

# On vérifie si le fichier preseed existe
if [[ ! -f $preseed_file ]]; then
	echo "Le fichier preseed n'existe pas"
	exit 1
fi

# On vérifie si le second argument est bien un fichier .iso
if [[ $iso_file != *.iso ]]; then
	echo "Le second argument doit être un fichier iso avec .iso comme extension"
	exit 1
fi

# On vérifie si le fichier iso existe
if [[ ! -f $iso_file ]]; then
	echo "Le fichier iso n'existe pas"
	exit 1
fi

# Si il n'y a pas de troisième arguments (pour le chemin de sortie), on dit que le chemin de sortie et le dossier actuel
if [[ -z $output_file ]];then
	output_file=$PWD
fi

# On ajoute le nom de sortie de l'iso au chemin de sortie
output_file=$output_file"/"$output_file_name

# On vérifie si les packages nécessaires sont installés
check_needed_packages

# On demande si il faut faire une installation complète
ask_for_auto_install

# On vérifie si le dossier de "travaille" existe, si il existe on demande de le supprimer
if [ -d $working_directory ]; then
	echo "Veuillez supprimer le dossier $working_directory"
	exit 1
fi

# On unpack l'iso avec xorriso
xorriso -osirrox on -indev $iso_file -extract / $working_directory

isXorrisoSuccessful=$?

# On donne les permissions de lecture et d'écriture à tout les fichier de l'iso
chmod -R +rw $working_directory

if [[ isXorrisoSuccessful -ne 0 ]]; then
	echo "Une erreur est survenue"
	clear_folder
	exit 1
fi

# On crée le fichier qui va contenir l'entrée du menu pour utiliser le preseed
cat > ${working_directory}isolinux/preseedMenu.cfg << EOF
label preseed
	menu label ^Utiliser le fichier preseed
	kernel /install.amd/vmlinuz
	append vga=788 initrd=/install.amd/initrd.gz auto=true file=/cdrom/preseed.cfg --- quiet
EOF

# On ajoute le fichier que l'on vient de créer à la fin de la liste des menus
echo "include preseedMenu.cfg" >> ${working_directory}isolinux/menu.cfg

# On copie le preseed dans l'iso
cp $preseed_file $working_directory
 
# Si l'auto install complete à été sélectionné, on remplace la ligne "default..." par "default preseed" dans isolinux.cfg
if [ $complete_auto_install = 1 ]; then
	sed -i 's/default.*/default preseed/g' $working_directory"isolinux/isolinux.cfg"
	echo "auto install"
fi

# On recompresse l'iso
mkisofs -o $output_file -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Debian preseed" $working_directory

clear_folder


# Info de fin
echo "===================================="
echo "L'iso modifié est ici : $output_file"

exit 0

