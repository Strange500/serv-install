manager install

create debian vm

1. add current user to sudoer in vm (both seed-manager & media-manager)

nano /etc/sudoers

add this line at the end :
username ALL=(ALL) NOPASSWD:ALL

2.create directories in host ( or media-manager vm depending on needs) <br>
cd ~ <br>
mkdir shared shared/media shared/manager <br>
cd shared/media <br>
mkdir anime show movie sorter temp torrent seed seed/anime seed/show seed/movie torrent/anime torrent/show torrent/movie sorter/anime sorter/show <br>sorter/movie<br>

3.Download Media-manager in manager vm
cd ../manager
wget https://github.com/Strange500/Media-manager/archive/refs/heads/main.zip
(if unzip not installed : sudo apt install unzip )
unzip main.zip
rm main.zip
cp -vr Media-manager-main/* .
rm -R Media-manager-main

4. Configure python env for all VM (refer to python.md ) 
   https://itslinuxfoss.com/how-to-install-python-on-debian-12/
   replace python-pip by python3-pip
   https://itslinuxfoss.com/install-pip-debian-12/
   pip install tmdbsimple psutil qbittorrent-api flask flask-cors flask_socketio bs4 feedparser fuzzywuzzy appdirs python-Levenshtein

6. mount shared folder in vm
   In virt-manager enable shared memory for each vm
   Then add file system pointing to the folder we ccreated before media and manager

   5.1
     In VM's do :
       cd ~
       mkdir media manager
       sudo nano /etc/fstab
       write this two lines (replace username with your username ) ( refer to https://sysguides.com/share-files-between-kvm-host-and-linux-guest-using-virtiofs/ ) 

         media /home/username/shared/media virtiofs defaults 0 0
         manager /home/username/shared/manager virtiofs defaults 0 0
7. launch main.py once in order to create the config files
      cd /home/username/manager/
      python3 main.py

8. Complete the config file
      cd ../.config/Media-Manager
      nano serv.conf
      complete every lines with the path of the folder we created before
