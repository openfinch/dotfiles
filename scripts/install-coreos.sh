#!/bin/bash

# Helper script for installing CoreOS

# Function to download CoreOS image
download_coreos_image() {
  local url="https://example.com/coreos-image"
  local output="coreos.img"
  echo "Downloading CoreOS image from $url..."
  curl -L -o "$output" "$url"
}

# Function to create bootable USB
create_bootable_usb() {
  local device=$1
  local image="coreos.img"
  echo "Creating bootable USB on $device..."
  sudo dd if="$image" of="$device" bs=4M status=progress
  sudo sync
}

# Function to install CoreOS
install_coreos() {
  local device=$1
  echo "Installing CoreOS on $device..."
  # Add your CoreOS installation steps here
}

# Main script execution
case "$1" in
  download)
    download_coreos_image
    ;;
  usb)
    if [ -z "$2" ]; then
      echo "Usage: $0 usb <device>"
      exit 1
    fi
    create_bootable_usb "$2"
    ;;
  install)
    if [ -z "$2" ]; then
      echo "Usage: $0 install <device>"
      exit 1
    fi
    install_coreos "$2"
    ;;
  *)
    echo "Usage: $0 {download|usb|install}"
    exit 1
    ;;
esac
