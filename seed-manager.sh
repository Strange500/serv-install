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

# Function to create or update manager.conf interactively
create_or_update_manager_conf() {
  local install_path="$1"

  # Define default values
  local redirect_directory="$install_path/shared/media"
  local seed_directories="$install_path/shared/media/seed/anime $install_path/shared/media/seed/movie $install_path/shared/media/seed/show"

  # Ask the user for other information
  read -p "Enter the number_of_bit_max: " number_of_bit_max
  read -p "Enter the day_delay: " day_delay
  read -p "Enter the qbittorrent_api_host: " qbittorrent_api_host
  read -p "Enter the qbittorrent_api_port: " qbittorrent_api_port
  read -p "Enter the username: " username
  read -p "Enter the password: " password

  # Define the manager.conf content
  local manager_conf_content="redirect_directory = $redirect_directory

seed_directory = $seed_directories

number_of_bit_max = $number_of_bit_max

day_delay = $day_delay

qbittorrent_api_host = $qbittorrent_api_host

qbittorrent_api_port = $qbittorrent_api_port

username = $username

password = $password"

  # Create or update the manager.conf file
  local manager_conf_file="$install_path/manager.conf"
  echo "$manager_conf_content" > "$manager_conf_file"

  echo "manager.conf created or updated in $manager_conf_file."
}
# Function to initialize the systemd service for Seed Manager
initialize_seed_manager_service() {
  local install_path="$1"
  local user="$USER"

  # Define the systemd service unit content
  local service_content="[Unit]
Description=Seed manager
After=network.target

[Service]
ExecStart=$install_path/env/venv/bin/python $install_path/main.py
WorkingDirectory=$install_path
User=$user
Restart=always

[Install]
WantedBy=multi-user.target"

  # Create the systemd service unit file
  local service_file="/etc/systemd/system/seed-manager.service"
  echo "$service_content" | sudo tee "$service_file" > /dev/null

  # Reload systemd to reflect changes
  sudo systemctl daemon-reload

  # Enable and start the service
  sudo systemctl enable seed-manager.service
  sudo systemctl start seed-manager.service

  echo "Systemd service 'seed-manager.service' has been initialized and started."
}

# Function to download and extract a zip file
download_and_extract_zip() {
  local install_path="$1"
  local zip_url="https://github.com/Strange500/seeder_manager/archive/refs/heads/main.zip"
  local zip_file="$install_path/main.zip"

  # Go to the installation directory
  cd "$install_path" || exit

  
  sudo apt-get install wget
  

  # Download the zip file
  wget "$zip_url" -O "$zip_file"

  # Check if the download was successful
  if [ -f "$zip_file" ]; then
    # Unzip the contents
    unzip "$zip_file"

    # Remove the zip file (optional)
    rm "$zip_file"

    # Move the contents of the unzipped folder to the installation directory
    mv seeder_manager-main/* .
    rm -r seeder_manager-main

    echo "Zip file downloaded, extracted, and cleanup completed in $install_path."
  else
    echo "Failed to download the zip file."
  fi
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

# Call the function to download and extract the zip file
download_and_extract_zip "$install_path"


# Call the function to create or update manager.conf
create_or_update_manager_conf "$install_path"


# Call the function to initialize the systemd service for Seed Manager
initialize_seed_manager_service "$install_path"



echo "Initialization completed in $install_path"
