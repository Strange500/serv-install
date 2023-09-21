#!/bin/bash

# Function to verify sudo rights
verify_sudo_rights() {
  if ! sudo -v; then
    echo "You don't have sudo rights. Please run this script with a user that has sudo privileges."
    exit 1
  fi
}

# Function to verify installation path
verify_installation_path() {
  read -p "Enter the installation path: " install_path

  # Check if the installation path is provided and valid
  if [ -z "$install_path" ]; then
    echo "Installation path not provided. Exiting."
    exit 1
  fi

  # Check if the path is writable
  if [ ! -w "$install_path" ]; then
    echo "The provided installation path is not writable. Please choose a different path."
    verify_installation_path
  fi
}

# Function to create required directories and subdirectories
create_directories() {
  local install_path="$1"

  # Create required directories
  local required_dirs=("shared" "shared/media" "shared/manager")

  for dir in "${required_dirs[@]}"; do
    local full_dir="$install_path/$dir"
    if [ ! -d "$full_dir" ]; then
      mkdir -p "$full_dir"
    fi
  done
}

# Function to create Python virtual environment
create_virtual_environment() {
  local install_path="$1"

  # Go to the installation directory
  cd "$install_path" || exit

  sudo apt install python3 python3-pip python3-virtualenv

  # Create the "env" directory and move into it
  mkdir -p env
  cd env || exit

  # Create a Python virtual environment named "venv"
  virtualenv -p python3 venv

  source venv/bin/activate

  pip install tmdbsimple psutil qbittorrent-api flask flask-cors flask_socketio bs4 feedparser fuzzywuzzy appdirs python-Levenshtein
}

# Function to add lines to /etc/fstab
add_lines_to_fstab() {
  local install_path="$1"

  read -p "Do you want to add lines to /etc/fstab? (yes/no): " answer

  if [ "$answer" == "yes" ]; then
    # Backup /etc/fstab
    sudo cp /etc/fstab /etc/fstab.bak

    # Add lines to /etc/fstab
    echo "media $install_path/shared/media virtiofs defaults 0 0" | sudo tee -a /etc/fstab
    echo "manager $install_path/shared/manager virtiofs defaults 0 0" | sudo tee -a /etc/fstab

    echo "Lines added to /etc/fstab. A backup of the original file is saved as /etc/fstab.bak."
  else
    echo "No lines were added to /etc/fstab."
  fi
}

# Function to create or update serv.conf interactively
create_or_update_serv_conf() {
  local user_home="$HOME"

  python "$install_path/shared/manager/main.py"

  # Check if serv.conf already exists
  local serv_conf_path="$user_home/.config/Media-Manager/server.conf"
  local overwrite_serv_conf="n"

  if [ -f "$serv_conf_path" ]; then
    read -p "serv.conf already exists. Do you want to overwrite it? (y/n): " overwrite_serv_conf
  fi

  if [ "$overwrite_serv_conf" == "y" ] || [ ! -f "$serv_conf_path" ]; then
    # Ask the user for each line of serv.conf
    echo "Please provide values for serv.conf (leave empty to skip):"

    # serv_dir
    serv_dir="$install_path"
    echo "serv_dir = $serv_dir"

    # show_dir
    show_dir="$install_path/shared/media/show"
    echo "shows_dir = $show_dir"

    # anime_dir
    anime_dir="$install_path/shared/media/anime"
    echo "anime_dir = $anime_dir"

    # movie_dir
    movie_dir="$install_path/shared/media/movie"
    echo "movie_dir = $movie_dir"

    # Downloader
    read -p "Downloader (TRUE/FALSE): " downloader
    if [ "$downloader" == "TRUE" ]; then
      download_dir="$install_path"
    else
      download_dir="$install_path"
    fi

    # TMDB_API_KEY
    read -p "Enter your TMDB API key (won't work without, leave empty to skip): " tmdb_api_key
    if [ -n "$tmdb_api_key" ]; then
      echo "TMDB_API_KEY = $tmdb_api_key"
    fi

    # Skip select_words_rss and banned_words_rss

    # sorter_anime_dir
    sorter_anime_dir="$install_path/shared/media/sorter/anime"
    echo "sorter_anime_dir = $sorter_anime_dir"

    # sorter_show_dir
    sorter_show_dir="$install_path/shared/media/sorter/show"
    echo "sorter_show_dir = $sorter_show_dir"

    # sorter_movie_dir
    sorter_movie_dir="$install_path/shared/media/sorter/movie"
    echo "sorter_movie_dir = $sorter_movie_dir"

    # temp_dir
    temp_dir="$install_path/shared/media/temp"
    echo "temp_dir = $temp_dir"

    # GGD_dir
    GGD_dir="$install_path"
    echo "GGD_dir = $GGD_dir"

    # Clip_load
    clip_load="$install_path"
    echo "clip_load = $clip_load"

    # Clip_lib
    clip_lib="$install_path"
    echo "clip_lib = $clip_lib"

    # GGD
    echo "GGD = FALSE"

    # Clip
    echo "Clip = FALSE"

    # torrent_dir
    torrent_dir="$install_path/shared/media/torrent"
    echo "torrent_dir = $torrent_dir"

    # errors_dir
    errors_dir="$install_path/shared/media/temp"
    echo "errors_dir = $errors_dir"

    # Write to serv.conf
    echo "# Enter the path to your installation" > "$serv_conf_path"
    echo "serv_dir = $serv_dir" >> "$serv_conf_path"
    echo "shows_dir = $show_dir" >> "$serv_conf_path"
    echo "anime_dir = $anime_dir" >> "$serv_conf_path"
    echo "movie_dir = $movie_dir" >> "$serv_conf_path"

    
    echo "Downloader = TRUE" >> "$serv_conf_path"
    echo "download_dir = $download_dir" >> "$serv_conf_path"
    

    if [ -n "$tmdb_api_key" ]; then
      echo "TMDB_API_KEY = $tmdb_api_key" >> "$serv_conf_path"
    fi

    echo "# Skip select_words_rss and banned_words_rss" >> "$serv_conf_path"

    echo "sorter_anime_dir = $sorter_anime_dir" >> "$serv_conf_path"
    echo "sorter_show_dir = $sorter_show_dir" >> "$serv_conf_path"
    echo "sorter_movie_dir = $sorter_movie_dir" >> "$serv_conf_path"
    echo "temp_dir = $temp_dir" >> "$serv_conf_path"

    echo "# GGD_dir, Clip_load, Clip_lib, GGD, Clip, torrent_dir, errors_dir" >> "$serv_conf_path"
    echo "GGD_dir = $GGD_dir" >> "$serv_conf_path"
    echo "Clip_load = $clip_load" >> "$serv_conf_path"
    echo "Clip_lib = $clip_lib" >> "$serv_conf_path"
    echo "GGD = FALSE" >> "$serv_conf_path"
    echo "Clip = FALSE" >> "$serv_conf_path"
    echo "torrent_dir = $torrent_dir" >> "$serv_conf_path"
    echo "errors_dir = $errors_dir" >> "$serv_conf_path"

    echo "serv.conf created or updated in $user_home/.config/Media-manager."
  fi
}

# Function to initialize the systemd service
initialize_systemd_service() {
  local install_path="$1"
  local user="$USER"

  # Define the systemd service unit content
  local service_content="[Unit]
Description=Automated media downloader sorter with web api
After=network.target

[Service]
ExecStart=$install_path/env/venv/bin/python $install_path/shared/manager/main.py
WorkingDirectory=$install_path/shared/manager
User=$user
Restart=always

[Install]
WantedBy=multi-user.target"

  # Create the systemd service unit file
  local service_file="/etc/systemd/system/media-manager.service"
  echo "$service_content" | sudo tee "$service_file" > /dev/null

  # Reload systemd to reflect changes
  sudo systemctl daemon-reload

  # Enable and start the service
  sudo systemctl enable media-manager.service
  sudo systemctl start media-manager.service

  echo "Systemd service 'media-manager.service' has been initialized and started."
}




# Verify sudo rights
verify_sudo_rights

# Verify installation path
verify_installation_path

# Create required directories and subdirectories
create_directories "$install_path"

# Create Python virtual environment
create_virtual_environment "$install_path"

# Add lines to /etc/fstab if the user wants
add_lines_to_fstab "$install_path"

# Launch the create_or_update_serv_conf function
create_or_update_serv_conf

initialize_systemd_service "$install_path"


echo "Initialization completed in $install_path"
