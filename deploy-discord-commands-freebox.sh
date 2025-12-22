#!/bin/bash

# 🚀 Script de Déploiement Global des Commandes Discord - Freebox
# Ce script déploie les commandes Discord (globales + guild) sur la Freebox

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
FREEBOX_IP="${FREEBOX_IP:-82.67.65.98}"
FREEBOX_PORT="${FREEBOX_PORT:-22222}"
FREEBOX_USER="${FREEBOX_USER:-bagbot}"
FREEBOX_PASSWORD="${FREEBOX_PASSWORD:-bagbot}"
BOT_DIR="/home/bagbot/Bag-bot"
REMOTE_MODE="${1:-ssh}"  # 'ssh' ou 'local'

# Fonctions d'affichage
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${PURPLE}ℹ️  $1${NC}"; }

echo "🚀 DÉPLOIEMENT GLOBAL DES COMMANDES DISCORD"
echo "==========================================="
echo ""

# Fonction de déploiement local (sur la Freebox)
deploy_local() {
    log "Mode déploiement LOCAL (directement sur Freebox)"
    
    if [[ ! -f "$BOT_DIR/deploy-commands.js" ]]; then
        error "Fichier deploy-commands.js introuvable dans $BOT_DIR"
        exit 1
    fi
    
    cd "$BOT_DIR"
    
    log "Vérification du fichier .env..."
    if [[ ! -f ".env" ]]; then
        error "Fichier .env manquant - configuration requise"
        exit 1
    fi
    
    if ! grep -q "DISCORD_TOKEN=" .env || ! grep -q "CLIENT_ID=" .env; then
        error "Fichier .env incomplet (DISCORD_TOKEN ou CLIENT_ID manquant)"
        exit 1
    fi
    
    success "Configuration .env validée"
    
    log "Déploiement des commandes Discord..."
    echo ""
    
    # Exécuter le déploiement
    node deploy-commands.js
    
    echo ""
    if [[ $? -eq 0 ]]; then
        success "🎉 Déploiement des commandes réussi !"
        echo ""
        info "📊 Résultat attendu:"
        echo "  • 47 commandes GLOBALES (serveur + MP)"
        echo "  • 46 commandes GUILD (serveur uniquement)"
        echo "  • Total: 93 commandes disponibles"
        echo ""
        warning "⏰ Les commandes peuvent prendre 5-10 minutes pour se synchroniser"
    else
        error "Échec du déploiement des commandes"
        exit 1
    fi
}

# Fonction de déploiement distant (via SSH)
deploy_remote() {
    log "Mode déploiement DISTANT (via SSH)"
    
    # Vérifier sshpass
    if ! command -v sshpass &> /dev/null; then
        warning "sshpass non installé, tentative d'installation..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y sshpass
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install hudochenkov/sshpass/sshpass
        else
            error "Impossible d'installer sshpass automatiquement"
            exit 1
        fi
    fi
    
    log "Test de connexion SSH à $FREEBOX_IP:$FREEBOX_PORT..."
    if ! sshpass -p "$FREEBOX_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "echo 'OK'" &>/dev/null; then
        error "Impossible de se connecter à la Freebox"
        echo ""
        info "Solutions possibles:"
        echo "  1. Vérifier que la Freebox est accessible à $FREEBOX_IP:$FREEBOX_PORT"
        echo "  2. Vérifier les identifiants SSH (user: $FREEBOX_USER)"
        echo "  3. Exécuter ce script directement sur la Freebox:"
        echo "     ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP"
        echo "     cd $BOT_DIR"
        echo "     bash deploy-discord-commands-freebox.sh local"
        echo ""
        exit 1
    fi
    
    success "Connexion SSH établie"
    
    log "Déploiement des commandes Discord sur la Freebox..."
    
    sshpass -p "$FREEBOX_PASSWORD" ssh -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'REMOTE_DEPLOY'
set -e

BOT_DIR="/home/bagbot/Bag-bot"
cd "$BOT_DIR"

echo "📍 Répertoire: $BOT_DIR"

# Vérification des fichiers
if [[ ! -f "deploy-commands.js" ]]; then
    echo "❌ Fichier deploy-commands.js introuvable"
    exit 1
fi

if [[ ! -f ".env" ]]; then
    echo "❌ Fichier .env manquant"
    exit 1
fi

echo "✅ Fichiers nécessaires présents"
echo ""
echo "🚀 Déploiement en cours..."
echo ""

# Exécuter le déploiement
node deploy-commands.js

if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ Déploiement réussi !"
else
    echo ""
    echo "❌ Erreur lors du déploiement"
    exit 1
fi
REMOTE_DEPLOY
    
    if [[ $? -eq 0 ]]; then
        success "🎉 Déploiement des commandes terminé avec succès !"
        echo ""
        info "📊 Résumé:"
        echo "  • Freebox: $FREEBOX_IP:$FREEBOX_PORT"
        echo "  • Répertoire: $BOT_DIR"
        echo "  • 47 commandes GLOBALES (serveur + MP)"
        echo "  • 46 commandes GUILD (serveur uniquement)"
        echo "  • Total: 93 commandes"
        echo ""
        warning "⏰ Synchronisation Discord: 5-10 minutes"
        echo ""
        info "🔍 Pour vérifier le déploiement:"
        echo "  ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP 'cd $BOT_DIR && node verify-commands.js'"
    else
        error "Échec du déploiement distant"
        exit 1
    fi
}

# Détection automatique du mode
if [[ "$REMOTE_MODE" == "local" ]]; then
    # Mode local : on est déjà sur la Freebox
    deploy_local
elif [[ -d "$BOT_DIR" ]]; then
    # Si le répertoire existe, on est probablement sur la Freebox
    warning "Répertoire $BOT_DIR détecté, basculement en mode local"
    deploy_local
else
    # Mode distant : connexion SSH nécessaire
    deploy_remote
fi

echo ""
success "✨ Script terminé !"
