#!/bin/sh
# Tableau qui contient les packages nécessaires pour l'éxecution du script
needed_packages=("xorriso" "genisoimage")
working_directory="./buildPressed/"
complete_auto_install=0

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
		exit
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
		non | Non | n | N | no | No | n | N ) complete_auto_install=0;;
		* ) echo "Veuillez répondre oui ou non";exit ;;
	esac
}

# On met les arguments dans des variables pour faciliter la lisibilité
preseed_file=$1
preseed_file_name=$(basename $preseed_file)
iso_file=$2
iso_file_name=$(basename $iso_file)
output_file=$3
output_file_name=${iso_file_name::-4}"_preseeded.iso"

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
if [[ -z $output_file ]];then
	output_file=$PWD
fi

# On ajoute le nom de l'iso suivi de _preseeded au chemin de destination
output_file=$output_file"/"$output_file_name

# On vérifie si les packages nécessaires sont installés
check_needed_packages

# On demande si il faut faire une installation complète
ask_for_auto_install

# On vérifie si le dossier existe, si il existe on demande de le supprimer
if [ -d $working_directory ] && [ 0 = 1 ]; then
	echo "Veuillez supprimer le dossier $working_directory"
fi

# On unpack l'iso avec xorriso
xorriso -osirrox on -indev $iso_file -extract / $working_directory

# On donne les permissions de lecture et d'écriture à tout les fichier de l'iso
chmod -R +rw $working_directory

# On crée le fichier qui va contenir l'entrée du menu pour utiliser le preseed
cat > ${working_directory}isolinux/preseedMenu.cfg << EOF
label preseed
	menu label ^Preseed
	kernel /install.amd/vmlinuz
	append vga=788 initrd=/install.amd/initrd.gz auto=true file=/cdrom/preseed.cfg --- quiet
EOF

# On ajoute le fichier que l'on vient de créer à la fin de la liste des menus
echo "include preseedMenu.cfg" >> ${working_directory}isolinux/menu.cfg


sed 's/a.*//' file


# On copie le preseed dans l'iso
cp $preseed_file $working_directory
 
# TODO 
# Si l'auto install complete à été sélectionné
#if [ complete_auto_install = 0 ]
#	default install prompt 0 timeout 0
#	sed 's/default.*//' $working_directory"isolinux/isolinux.cfg" >> $working_directory"isolinux/isolinux.cfg"
#fi


# On recompresse l'iso 
mkisofs -o $output_file_name -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Debian preseed" $working_directory

# On supprime le dossier
rm -rf $working_directory



# Info de fin
echo "===================================="
echo "L'iso modifié est ici : $output_file"



