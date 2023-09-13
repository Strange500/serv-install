manager install

create debian vm

1. add current user to sudoer

nano /etc/sudoers

add this line at the end :
username ALL=(ALL) NOPASSWD:ALL

2.create directories
cd ~
mkdir media manager
cd media
mkdir anime show movie sorter temp torrent seed seed/anime seed/show seed/movie torrent/anime torrent/show torrent/movie sorter/anime sorter/show sorter/movie

3.Download Media-manager
cd ../manager
wget https://github.com/Strange500/Media-manager/archive/refs/heads/main.zip
(if unzip not installed : sudo apt install unzip )
unzip main.zip
rm main.zip
cp -vr Media-manager-main/* .
rm -R Media-manager-main








create
