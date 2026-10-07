#!/usr/bin/env bash

set -Eeuo pipefail


# ============================================================
# ZSH BOOTSTRAP
# ============================================================

PROJECT_NAME="zsh-bootstrap"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"

BACKUP_DATE="$(date '+%Y%m%d-%H%M%S')"


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
# LOAD MODULES
# ============================================================

source "$SCRIPTS_DIR/detect-os.sh"
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
        git -C "$destination" pull --ff-only >/dev/null

    else

        info "Installation de $plugin_name..."

        git clone \
            --depth=1 \
            "$repository" \
            "$destination"

    fi
}


install_plugin \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "zsh-autosuggestions"

install_plugin \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "zsh-syntax-highlighting"

install_plugin \
    "https://github.com/zsh-users/zsh-completions" \
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

CURRENT_USER="${USER:-$(id -un)}"

CURRENT_SHELL="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then

    info "Configuration de Zsh comme shell par défaut..."

    if chsh -s "$ZSH_PATH"; then
        success "Zsh est maintenant le shell par défaut."
    else
        warning "Impossible de modifier automatiquement le shell."
        warning "Commande à exécuter manuellement :"
        echo
        echo "    chsh -s $ZSH_PATH"
        echo
    fi

else

    success "Zsh est déjà le shell par défaut."

fi


# ============================================================
# END
# ============================================================

echo
echo "======================================"
echo "        Installation terminée"
echo "======================================"
echo
echo "Lance :"
echo
echo "    exec zsh"
echo
