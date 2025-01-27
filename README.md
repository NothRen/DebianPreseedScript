# Debian preseed script


Ce script permet de modifier un ISO Debian pour y ajouter un fichier preseed. Les fichiers preseed sont utilisés pour automatiser l'installation. 

J'ai testé ce script avec la version *debian-12.8.0-amd64-netinst.iso* de Debian.

Le script a trois paramètres en entrée :
1. le fichier preseed (qui doit avoir .cfg en extension)
2. le fichier ISO (qui doit avoir .iso en extension)
3. (Optionnel) le chemin de sortie


Pour générer un preseed à partir d'une installation existante de Debian, vous pouvez installer le package *debconf-utils* puis utiliser la commande : 

```debconf-get-selections --installer```

Note : Le fichier preseed dans le repo est basé sur [ce preseed](https://www.debian.org/releases/stable/example-preseed.txt). Je ne recommande pas de l'utiliser dans l'état.

## Packages nécessaires :
Les packages apt suivants sont nécessaires pour exécuter le script :

| Packages | Versions |
| ------- | ------- |
| xorriso | 1.5.4-2 |
| genisoimage | 9:1.1.11-3.2ubuntu1 |

Vous pourrez peut-être utiliser le script avec des versions plus anciennes des packages, mais je ne le garantis pas.


## Utilisation :
Pour exécuter le script :
1. Avoir une distribution basée sur Debian
2. Télécharger une [image netinst de Debian](https://www.debian.org/distrib/netinst)
3. Créer un fichier [preseed](https://wiki.debian.org/fr/DebianInstaller/Preseed) qui corresponde à votre besoin. ([Exemple de preseed](https://www.debian.org/releases/stable/example-preseed.txt))
4. Cloner/Télécharger ce repo
5. Installer les packages nécessaires : ```apt install xorriso genisoimage```
6. Exécuter le script : ```bash AddPreseedToIso.sh  /chemin/vers/preseed.cfg /chemin/vers/debian-12.x.x-amd64-netinst.iso /chemin/de/sortie```
7. Pendant l'exécution du script, il vous sera demandé si vous voulez une "auto installation complète". Si vous répondez oui, l'ISO utilisera automatiquement le preseed et vous ne pourrez plus l'installer "normalement".
8. Utiliser l'ISO. En cas "d'auto installation complète" l'ISO s'installera tout seul. Mais si vous ne l'avez pas sélectionné, une option supplémentaire apparaîtra en bas du menu : "Utiliser le fichier preseed".



## Liens utiles :
Liste non exhaustive de liens qui m'ont aidé :

- https://gist.github.com/AkdM/2cd3766236582ed0263920d42c359e0f
- https://www.debian.org/releases/bookworm/example-preseed.txt
- https://stackoverflow.com/questions/65342504/how-to-auto-select-menu-entry-bybass-grub-menu-in-custom-debian-iso
- https://superuser.com/questions/1181212/build-debian-preseed-after-the-options-selected-on-a-normal-installation
- https://www.pugetsystems.com/labs/hpc/Note-Auto-Install-Ubuntu-with-Custom-Preseed-ISO-1654/
- https://debian-facile.org/doc:install:preseed
