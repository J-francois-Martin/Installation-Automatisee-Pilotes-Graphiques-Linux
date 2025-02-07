#!/bin/bash

# Vérifier si l'utilisateur est root
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que sudo."
  echo "Veuillez entrer le mot de passe sudo pour continuer."
  exec sudo bash "$0" "$@"
  if [ $? -ne 0 ]; then
    echo "Échec de l'authentification. Ce script doit être exécuté en tant que sudo."
    exit 1
  fi
  exit 0
fi

# Vérifier si zenity est installé, sinon l'installer
if ! command -v zenity &> /dev/null; then
  echo "Zenity n'est pas installé. Installation en cours..."
  apt update
  apt install -y zenity
  if [ $? -ne 0 ]; then
    echo "Échec de l'installation de Zenity. Veuillez l'installer manuellement."
    exit 1
  fi
  echo "Zenity installé avec succès."
fi

# Déterminer l'architecture du système
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
  zenity --error --text="Ce script est conçu pour les systèmes amd64 (x86_64)"
  exit 1
fi

# Vérifier les versions des pilotes Nvidia et CUDA s'ils sont installés
nvidia_installed_version=""
cuda_installed_version=""

if command -v nvidia-smi &> /dev/null; then
  nvidia_installed_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
fi

if command -v nvcc &> /dev/null; then
  cuda_installed_version=$(nvcc --version | grep "release" | awk '{print $6}' | sed 's/,//')
fi

# Afficher les versions installées au démarrage
installed_versions_message="Versions installées:\n\n"
if [ -n "$nvidia_installed_version" ]; then
  installed_versions_message+="Pilote Nvidia : $nvidia_installed_version\n"
else
  installed_versions_message+="Pilote Nvidia : Non installé\n"
fi

if [ -n "$cuda_installed_version" ]; then
  installed_versions_message+="Toolkit CUDA : $cuda_installed_version\n"
else
  installed_versions_message+="Toolkit CUDA : Non installé\n"
fi

zenity --info --text="$installed_versions_message"

# Fenêtre de sélection du type de pilote
DRIVER_TYPE=$(zenity --list --title="Sélection du type de pilote" --radiolist \
  --column="Sélection" --column="Type de pilote" \
  TRUE "Nvidia" FALSE "AMD" FALSE "Quitter")

if [ "$DRIVER_TYPE" == "Quitter" ]; then
  zenity --info --text="Vous avez choisi de quitter. Au revoir!"
  exit 0
fi

if [ -z "$DRIVER_TYPE" ]; then
  zenity --error --text="Aucun type de pilote sélectionné"
  exit 1
fi

# Demander une confirmation avant de procéder à l'installation
if ! zenity --question --text="Attention, vous allez procéder à l'installation du pilote $DRIVER_TYPE. Voulez-vous continuer ?"; then
  zenity --info --text="Installation annulée."
  exit 0
fi

# Fonction pour installer ou réinstaller les pilotes Nvidia avec option CUDA
install_nvidia() {
  # Ajouter le référentiel contrib et non-free
  echo "Ajout des sections contrib et non-free aux sources..."
  sed -i '/^deb/s/$/ contrib non-free/' /etc/apt/sources.list

  # Mettre à jour la liste des paquets
  echo "Mise à jour de la liste des paquets..."
  apt update

  # Installer ou réinstaller les pré-requis et les paquets Nvidia et CUDA
  echo "Installation ou réinstallation des pré-requis et des pilotes Nvidia et CUDA..."
  apt install -y linux-headers-amd64 nvidia-driver nvidia-settings nvidia-cuda-toolkit nvidia-cuda-dev vulkan-tools --reinstall
}

# Fonction pour installer ou réinstaller les pilotes AMD
install_amd() {
  # Ajouter le référentiel officiel AMD pour les pilotes
  echo "Ajout du référentiel AMD..."
  add-apt-repository ppa:oibaf/graphics-drivers -y

  # Mettre à jour la liste des paquets
  echo "Mise à jour de la liste des paquets..."
  apt update

  # Installer ou réinstaller les pré-requis et les pilotes AMD
  echo "Installation ou réinstallation des pré-requis et des pilotes AMD..."
  apt install -y linux-headers-amd64 mesa-vulkan-drivers mesa-vulkan-drivers:i386 --reinstall
}

# Installation ou réinstallation des pilotes en fonction du type sélectionné
if [ "$DRIVER_TYPE" == "Nvidia" ]; then
  zenity --info --text="Installation du pilote Nvidia avec CUDA..."
  install_nvidia
elif [ "$DRIVER_TYPE" == "AMD" ]; then
  zenity --info --text="Installation du pilote AMD..."
  install_amd
fi

# Vérification de l'installation
if [ "$DRIVER_TYPE" == "Nvidia" ]; then
  dpkg -l | grep -i nvidia
elif [ "$DRIVER_TYPE" == "AMD" ]; then
  dpkg -l | grep -i mesa-vulkan-drivers
fi

zenity --info --text="Installation terminée. Veuillez redémarrer votre système pour que les modifications prennent effet."

# Redémarrer le système (optionnel)
if zenity --question --text="Voulez-vous redémarrer maintenant?"; then
  reboot
fi
