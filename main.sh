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

  # Create subdirectories within "shared/media"
  local media_subdirs=("anime" "show" "movie" "sorter" "temp" "torrent" "seed")

  for subdir in "${media_subdirs[@]}"; do
    local full_dir="$install_path/shared/media/$subdir"
    if [ ! -d "$full_dir" ]; then
      mkdir -p "$full_dir"
    fi
  done

  # Create subdirectories within "sorter," "torrent," and "seed"
  local sorter_subdirs=("anime" "show" "movie")
  local torrent_subdirs=("anime" "show" "movie")
  local seed_subdirs=("anime" "show" "movie")

  for subdir in "${sorter_subdirs[@]}" "${torrent_subdirs[@]}" "${seed_subdirs[@]}"; do
    local full_dir="$install_path/shared/media/sorter/$subdir"
    if [ ! -d "$full_dir" ]; then
      mkdir -p "$full_dir"
    fi

    full_dir="$install_path/shared/media/torrent/$subdir"
    if [ ! -d "$full_dir" ]; then
      mkdir -p "$full_dir"
    fi

    full_dir="$install_path/shared/media/seed/$subdir"
    if [ ! -d "$full_dir" ]; then
      mkdir -p "$full_dir"
    fi
  done
}

# Function to download and unzip the file
download_and_unzip() {
  local install_path="$1"

  # Go to the "manager" folder
  cd "$install_path/shared/manager" || exit

  # Install wget if not already installed
  if ! command -v wget &>/dev/null; then
    sudo apt-get update
    sudo apt-get install wget
  fi

  # Download the zip file
  wget https://github.com/Strange500/Media-manager/archive/refs/heads/main.zip

  # Unzip the contents into the "manager" folder
  unzip main.zip

  # Clean up the zip file (optional)
  rm main.zip

  # Move the contents of the unzipped folder to the current directory
  mv Media-manager-main/* .
  rm -r Media-manager-main
}

# Verify sudo rights
verify_sudo_rights

# Verify installation path
verify_installation_path

# Create required directories and subdirectories
create_directories "$install_path"

# Download and unzip the file into the "manager" folder
download_and_unzip "$install_path"


echo "Initialization completed in $install_path"
