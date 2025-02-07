# Installation-Automatisee-Pilotes-Graphiques-Linux
Script bash pour installer automatiquement les pilotes graphiques Nvidia et AMD sur Linux Debian/Ubuntu.interface graphique via Zenity pour une installation sécurisée et conviviale.
# Installation Automatisée de Pilotes Graphiques

Ce script bash est conçu pour simplifier l'installation des pilotes graphiques Nvidia et AMD sur des systèmes Linux basés sur Debian/Ubuntu.

Voici un exemple complet des commandes que vous pourriez utiliser :
- * Rendre le script exécutable 
- ```bash
   chmod +x install_drivers.sh
- * Après avoir ajouté un utilisateur au groupe sudo, l'utilisateur devra soit se déconnecter et se reconnecter,
  * soit redémarrer son shell pour que les changements prennent effet.
- ```bash
  su -c "usermod -aG sudo $USER"
- * Exécuter le script 
- ```bash
  sudo ./install_drivers.sh  

## Prérequis

- **Privilèges sudo** : Le script doit être exécuté avec des privilèges sudo.
- **Zenity** : Utilisé pour l'interface graphique. Si non installé, le script propose son installation.
- **Architecture** : Seulement compatible avec les architectures x86_64.

## Fonctionnalités

- **Vérification des Privilèges** : Assure que le script est exécuté avec les droits nécessaires.
- **Installation de Zenity** : Installe Zenity si non présent.
- **Détection de l'Architecture** : Vérifie que le système est compatible avant de procéder.
- **Affichage des Versions** : Montre les versions actuelles des pilotes Nvidia et CUDA installés.
- **Sélection des Pilotes** : Permet à l'utilisateur de choisir entre Nvidia ou AMD.
- **Installation Sécurisée** : Propose une confirmation avant d'installer ou de réinstaller les pilotes.
- **Post-Installation** : Informe l'utilisateur de l'état de l'installation et suggère un redémarrage.

## Utilisation

1. **Cloner le dépôt** :
   ```bash
   git clone [https://github.com/J-francois-Martin/Installation-Automatisee-Pilotes-Graphiques-Linux.git]
