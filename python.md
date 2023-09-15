to configure Python there is 2 possibility:
  1. Your python is not externaly managed
  2. Your Python is externally mananged

For 1. you won't need additional steps just do sudo apt install pip

For 2. you will need to configure an virtual environement for Python

1. sudo apt install python3 python3-pip
2. install package : sudo pip3 install virtualenv
3. create a directory to store you venv
   mkdir ~/env
   cd ~/env
4.initialize venv
   virtualenv -p python3 venv
5. activate venv
   source venv/bin/activate
   5.1 (optionnal) modify bashrc
     nano ~/.bashrc
     add this line
     source /home/username/env/venv/bin/activate
     
