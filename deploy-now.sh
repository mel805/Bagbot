#!/bin/bash
# 🚀 Déploiement Rapide des Commandes Discord - Freebox
# Usage: ./deploy-now.sh [local|remote]

set -e

# Configuration
FREEBOX_IP="82.67.65.98"
FREEBOX_PORT="33000"
FREEBOX_USER="bagbot"
FREEBOX_PASSWORD="bagbot"
BOT_DIR="/home/bagbot/Bag-bot"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 DÉPLOIEMENT COMMANDES DISCORD        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Détection automatique du mode
if [[ -d "$BOT_DIR" ]]; then
    MODE="local"
    echo -e "${GREEN}✓ Mode LOCAL détecté (sur la Freebox)${NC}"
else
    MODE="remote"
    echo -e "${YELLOW}⚡ Mode DISTANT (via SSH)${NC}"
fi

# Mode local : exécution directe
if [[ "$MODE" == "local" ]]; then
    cd "$BOT_DIR"
    
    if [[ ! -f ".env" ]] || [[ ! -f "deploy-commands.js" ]]; then
        echo -e "${RED}✗ Fichiers manquants${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📦 Déploiement en cours...${NC}"
    echo ""
    
    node deploy-commands.js
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║          ✓ DÉPLOIEMENT RÉUSSI !           ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${BLUE}•${NC} 47 commandes globales (serveur + MP)"
        echo -e "  ${BLUE}•${NC} 46 commandes guild (serveur uniquement)"
        echo -e "  ${BLUE}•${NC} Total: 93 commandes"
        echo ""
        echo -e "${YELLOW}⏰ Synchronisation Discord: 5-10 min${NC}"
    else
        echo -e "${RED}✗ Échec du déploiement${NC}"
        exit 1
    fi
    
# Mode distant : connexion SSH
else
    if ! command -v sshpass &> /dev/null; then
        echo -e "${YELLOW}⚠️  Installation de sshpass...${NC}"
        sudo apt-get update -qq && sudo apt-get install -y -qq sshpass
    fi
    
    echo -e "${BLUE}🔌 Connexion à $FREEBOX_IP:$FREEBOX_PORT...${NC}"
    
    if ! sshpass -p "$FREEBOX_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "echo OK" &>/dev/null; then
        echo -e "${RED}✗ Connexion impossible${NC}"
        echo ""
        echo -e "${YELLOW}💡 Solutions:${NC}"
        echo "  1. Vérifier que la Freebox est allumée"
        echo "  2. Vérifier l'IP: $FREEBOX_IP"
        echo "  3. Vérifier le port SSH: $FREEBOX_PORT"
        echo ""
        echo -e "${BLUE}📋 Commande manuelle:${NC}"
        echo "  ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP"
        echo "  cd $BOT_DIR"
        echo "  node deploy-commands.js"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Connecté${NC}"
    echo -e "${BLUE}📦 Déploiement en cours...${NC}"
    echo ""
    
    sshpass -p "$FREEBOX_PASSWORD" ssh -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'ENDSSH'
cd /home/bagbot/Bag-bot
node deploy-commands.js
ENDSSH
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║          ✓ DÉPLOIEMENT RÉUSSI !           ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${BLUE}•${NC} Freebox: $FREEBOX_IP:$FREEBOX_PORT"
        echo -e "  ${BLUE}•${NC} 47 commandes globales (serveur + MP)"
        echo -e "  ${BLUE}•${NC} 46 commandes guild (serveur uniquement)"
        echo -e "  ${BLUE}•${NC} Total: 93 commandes"
        echo ""
        echo -e "${YELLOW}⏰ Synchronisation Discord: 5-10 min${NC}"
    else
        echo -e "${RED}✗ Échec du déploiement${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}✨ Terminé !${NC}"
