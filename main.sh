echo "Bienvenue sur le programme d'installation de media-manager serveur principale"

sudo -n true

if [ $? -eq 0 ]; then
    echo ""
else
    echo "Vous devez lancer le script avec les droits sudo"
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
mkdir -p shared/media/anime shared/media/show shared/media/movie shared/media/sorter shared/media/temp shared/media/torrent shared/media/seed shared/media/seed/anime shared/media/seed/show shared/media/seed/movie shared/media/torrent/anime shared/media/torrent/show shared/media/torrent/movie shared/media/sorter/anime shared/media/sorter/show shared/media/sorter/movie 
wget https://github.com/Strange500/Media-manager/archive/refs/heads/main.zip
unzip main.zip
rm main.zip
cp -vr Media-manager-main/* shared/manager
rm -R Media-manager-main

echo $install_path

	


exit
