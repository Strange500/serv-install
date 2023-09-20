#!/bin/bash
# media-manager.sh


echo "Bienvenue sur le programme d'installation de media-manager"

sudo -n true

if [ $? -eq 0 ]; then
    echo ""
else
    echo "Vous devez lancer le script avec les droits sudo"
    exit
fi
while true; do

	read -p "ou souhaitez vous installer media-manager ? " install_path
	
	if [ -d "$install_path" ]; then
		echo "chemin correcte"
		break
	else
		echo "le chemin entrer est incorrecte"
	fi
done
cd $install_path
mkdir -p shared shared/media shared/manager
cp /etc/fstab .
echo "" >> /etc/fstab
echo "media $install_path/shared/media virtiofs defaults 0 0" >> /etc/fstab
echo "" >> /etc/fstab
echo "manager $install_path/shared/manager virtiofs defaults 0 0" >> /etc/fstab




mkdir env
apt install python3 python3-pip python3-virtualenv
cd env
virtualenv -p python3 venv
source venv/bin/activate
pip install tmdbsimple psutil qbittorrent-api flask flask-cors flask_socketio bs4 feedparser fuzzywuzzy appdirs python-Levenshtein


echo $install_path

	


exit

