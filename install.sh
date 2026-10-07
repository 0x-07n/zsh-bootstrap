#!/usr/bin/env bash

set -Eeuo pipefail


# ============================================================
# ZSH BOOTSTRAP
# ============================================================

REPO_URL="https://github.com/0x-07n/zsh-bootstrap.git"
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-bootstrap"


# ============================================================
# COLORS
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'


info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}


# ============================================================
# HEADER
# ============================================================

echo
echo "======================================"
echo "       ZSH Universal Bootstrap"
echo "======================================"
echo


# ============================================================
# BOOTSTRAP MODE
# ============================================================
#
# Si le script est lancé avec :
#
# curl .../install.sh | bash
#
# les fichiers config/ et scripts/ n'existent pas encore.
# On clone donc automatiquement le repository puis on relance
# ce même script depuis le clone local.
# ============================================================

if [[ "${1:-}" != "--local" ]]; then

    if ! command -v git >/dev/null 2>&1; then

    	info "Git n'est pas installé."

    	if command -v apt-get >/dev/null 2>&1; then

        	info "Installation de Git avec apt..."
        	sudo apt-get update
        	sudo apt-get install -y git curl

    	elif command -v dnf >/dev/null 2>&1; then

        	info "Installation de Git avec dnf..."
        	sudo dnf install -y git curl

    	elif command -v pacman >/dev/null 2>&1; then

        	info "Installation de Git avec pacman..."
        	sudo pacman -Sy --needed --noconfirm git curl

    	elif command -v zypper >/dev/null 2>&1; then

        	info "Installation de Git avec zypper..."
        	sudo zypper --non-interactive install git curl

    	else

        	error "Impossible d'installer Git automatiquement."
        	exit 1

    	fi

    fi

    mkdir -p "$(dirname "$INSTALL_DIR")"

    if [[ -d "$INSTALL_DIR/.git" ]]; then

        info "Installation existante détectée."
        info "Mise à jour du repository..."

        git -C "$INSTALL_DIR" pull --ff-only

    else

        if [[ -e "$INSTALL_DIR" ]]; then
            error "$INSTALL_DIR existe mais n'est pas un repository Git."
            exit 1
        fi

        info "Téléchargement de zsh-bootstrap..."

        git clone \
            --depth=1 \
            "$REPO_URL" \
            "$INSTALL_DIR"

    fi

    success "Repository disponible dans : $INSTALL_DIR"

    echo

    exec bash "$INSTALL_DIR/install.sh" --local
fi


# ============================================================
# LOCAL MODE
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"

BACKUP_DATE="$(date '+%Y%m%d-%H%M%S')"


# ============================================================
# VALIDATION
# ============================================================

if [[ ! -f "$SCRIPTS_DIR/detect-os.sh" ]]; then
    error "Fichier manquant : scripts/detect-os.sh"
    exit 1
fi

if [[ ! -f "$SCRIPTS_DIR/install-packages.sh" ]]; then
    error "Fichier manquant : scripts/install-packages.sh"
    exit 1
fi

if [[ ! -f "$CONFIG_DIR/zshrc" ]]; then
    error "Fichier manquant : config/zshrc"
    exit 1
fi

if [[ ! -f "$CONFIG_DIR/starship.toml" ]]; then
    error "Fichier manquant : config/starship.toml"
    exit 1
fi


# ============================================================
# LOAD MODULES
# ============================================================

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/detect-os.sh"

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/install-packages.sh"


# ============================================================
# OS DETECTION
# ============================================================

detect_os

info "Distribution : $DISTRO_NAME"
info "Package manager : $PACKAGE_MANAGER"

if [[ "$PACKAGE_MANAGER" == "unknown" ]]; then
    error "Cette distribution n'est pas encore supportée."
    exit 1
fi


# ============================================================
# PACKAGES
# ============================================================

install_packages

success "Dépendances installées."


# ============================================================
# OH MY ZSH
# ============================================================

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then

    info "Installation de Oh My Zsh..."

    RUNZSH=no \
    CHSH=no \
    KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    success "Oh My Zsh installé."

else

    success "Oh My Zsh déjà installé."

fi


# ============================================================
# ZSH PLUGINS
# ============================================================

mkdir -p "$ZSH_CUSTOM_DIR/plugins"


install_plugin() {

    local repository="$1"
    local plugin_name="$2"

    local destination="$ZSH_CUSTOM_DIR/plugins/$plugin_name"

    if [[ -d "$destination/.git" ]]; then

        info "Mise à jour de $plugin_name..."

        git -C "$destination" pull --ff-only || \
            warning "Impossible de mettre à jour $plugin_name."

    elif [[ -e "$destination" ]]; then

        warning "$destination existe déjà mais n'est pas un repo Git."

    else

        info "Installation de $plugin_name..."

        git clone \
            --depth=1 \
            "$repository" \
            "$destination"

    fi
}


install_plugin \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "zsh-autosuggestions"

install_plugin \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "zsh-syntax-highlighting"

install_plugin \
    "https://github.com/zsh-users/zsh-completions.git" \
    "zsh-completions"

success "Plugins Zsh installés."


# ============================================================
# STARSHIP
# ============================================================

if ! command -v starship >/dev/null 2>&1; then

    info "Installation de Starship..."

    curl -sS https://starship.rs/install.sh | sh -s -- -y

    success "Starship installé."

else

    success "Starship déjà installé."

fi


# ============================================================
# BACKUPS
# ============================================================

if [[ -f "$HOME/.zshrc" ]]; then

    cp \
        "$HOME/.zshrc" \
        "$HOME/.zshrc.backup-$BACKUP_DATE"

    success "Backup ~/.zshrc créé."

fi


if [[ -f "$HOME/.config/starship.toml" ]]; then

    cp \
        "$HOME/.config/starship.toml" \
        "$HOME/.config/starship.toml.backup-$BACKUP_DATE"

    success "Backup Starship créé."

fi


# ============================================================
# INSTALL CONFIG
# ============================================================

mkdir -p "$HOME/.config"

cp \
    "$CONFIG_DIR/zshrc" \
    "$HOME/.zshrc"

cp \
    "$CONFIG_DIR/starship.toml" \
    "$HOME/.config/starship.toml"

success "Configuration Zsh installée."
success "Configuration Starship installée."


# ============================================================
# DEFAULT SHELL
# ============================================================

ZSH_PATH="$(command -v zsh)"

CURRENT_USER="$(id -un)"

CURRENT_SHELL="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then

    info "Configuration de Zsh comme shell par défaut..."

    if chsh -s "$ZSH_PATH"; then

        success "Zsh est maintenant le shell par défaut."

    else

        warning "Impossible de modifier automatiquement le shell."
        warning "Exécute manuellement :"
        echo
        echo "    chsh -s $ZSH_PATH"
        echo

    fi

else

    success "Zsh est déjà le shell par défaut."

fi

# ============================================================
# ZSH-BOOTSTRAP CLI
# ============================================================

mkdir -p "$HOME/.local/bin"

ln -sf \
    "$INSTALL_DIR/bin/zsh-bootstrap" \
    "$HOME/.local/bin/zsh-bootstrap"

success "Commande zsh-bootstrap installée."

# ============================================================
# END
# ============================================================

echo
echo "======================================"
echo "        Installation terminée"
echo "======================================"
echo
echo "Repository local :"
echo
echo "    $INSTALL_DIR"
echo
echo "Pour appliquer Zsh immédiatement :"
echo
echo "    exec zsh"
echo
