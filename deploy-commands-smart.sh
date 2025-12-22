#!/bin/bash

# 🎯 Script Intelligent de Déploiement - Détection Automatique
# Essaie plusieurs méthodes pour déployer les commandes Discord

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
FREEBOX_IP="${FREEBOX_IP:-82.67.65.98}"
FREEBOX_PORT="${FREEBOX_PORT:-22222}"
FREEBOX_USER="${FREEBOX_USER:-bagbot}"
FREEBOX_PASSWORD="${FREEBOX_PASSWORD:-bagbot}"
BOT_DIR="/home/bagbot/Bag-bot"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   🚀 DÉPLOIEMENT INTELLIGENT - COMMANDES DISCORD     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Fonction 1 : Déploiement LOCAL (on est sur la Freebox)
try_local_deploy() {
    echo -e "${BLUE}[Méthode 1]${NC} Tentative de déploiement LOCAL..."
    
    if [[ -d "$BOT_DIR" ]] && [[ -f "$BOT_DIR/deploy-commands.js" ]]; then
        echo -e "${GREEN}✓${NC} Répertoire détecté : $BOT_DIR"
        cd "$BOT_DIR"
        
        if [[ ! -f ".env" ]]; then
            echo -e "${RED}✗${NC} Fichier .env manquant"
            return 1
        fi
        
        echo -e "${BLUE}→${NC} Déploiement en cours..."
        if node deploy-commands.js; then
            echo -e "${GREEN}✓${NC} Déploiement LOCAL réussi !"
            return 0
        else
            echo -e "${RED}✗${NC} Échec du déploiement"
            return 1
        fi
    else
        echo -e "${YELLOW}⊘${NC} Pas sur la Freebox (répertoire $BOT_DIR introuvable)"
        return 1
    fi
}

# Fonction 2 : Déploiement via SSH avec sshpass
try_ssh_deploy() {
    echo -e "\n${BLUE}[Méthode 2]${NC} Tentative de déploiement via SSH (sshpass)..."
    
    if ! command -v sshpass &> /dev/null; then
        echo -e "${YELLOW}⊘${NC} sshpass non installé"
        return 1
    fi
    
    echo -e "${BLUE}→${NC} Test de connexion à $FREEBOX_IP:$FREEBOX_PORT..."
    
    if timeout 10 sshpass -p "$FREEBOX_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=8 -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "echo OK" &>/dev/null; then
        echo -e "${GREEN}✓${NC} Connexion SSH établie"
        
        echo -e "${BLUE}→${NC} Déploiement des commandes..."
        if sshpass -p "$FREEBOX_PASSWORD" ssh -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "cd $BOT_DIR && node deploy-commands.js"; then
            echo -e "${GREEN}✓${NC} Déploiement SSH réussi !"
            return 0
        else
            echo -e "${RED}✗${NC} Échec du déploiement"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} Connexion SSH impossible (timeout ou refusée)"
        return 1
    fi
}

# Fonction 3 : Déploiement via SSH standard (avec clé)
try_ssh_key_deploy() {
    echo -e "\n${BLUE}[Méthode 3]${NC} Tentative de déploiement via SSH (clé)..."
    
    if ! command -v ssh &> /dev/null; then
        echo -e "${YELLOW}⊘${NC} SSH non disponible"
        return 1
    fi
    
    echo -e "${BLUE}→${NC} Test de connexion SSH (clé) à $FREEBOX_IP:$FREEBOX_PORT..."
    
    if timeout 10 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=8 -o BatchMode=yes -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "echo OK" &>/dev/null; then
        echo -e "${GREEN}✓${NC} Connexion SSH (clé) établie"
        
        echo -e "${BLUE}→${NC} Déploiement des commandes..."
        if ssh -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "cd $BOT_DIR && node deploy-commands.js"; then
            echo -e "${GREEN}✓${NC} Déploiement SSH (clé) réussi !"
            return 0
        else
            echo -e "${RED}✗${NC} Échec du déploiement"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} Connexion SSH (clé) impossible"
        return 1
    fi
}

# Fonction 4 : Instructions manuelles
show_manual_instructions() {
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════╗"
    echo -e "║  ⚠️  DÉPLOIEMENT MANUEL REQUIS                      ║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}La Freebox n'est pas accessible depuis cet environnement.${NC}"
    echo ""
    echo -e "${BLUE}📋 Instructions :${NC}"
    echo ""
    echo -e "${YELLOW}Option 1 : Depuis votre machine locale${NC}"
    echo "  1. Ouvrir un terminal"
    echo "  2. Se connecter à la Freebox :"
    echo -e "     ${GREEN}ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP${NC}"
    echo "  3. Aller dans le répertoire :"
    echo -e "     ${GREEN}cd $BOT_DIR${NC}"
    echo "  4. Déployer les commandes :"
    echo -e "     ${GREEN}node deploy-commands.js${NC}"
    echo ""
    echo -e "${YELLOW}Option 2 : Commande unique${NC}"
    echo -e "  ${GREEN}ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP 'cd $BOT_DIR && node deploy-commands.js'${NC}"
    echo ""
    echo -e "${YELLOW}Option 3 : Utiliser le script local${NC}"
    echo "  1. Copier le fichier deploy-commands-freebox-local.sh sur la Freebox"
    echo "  2. L'exécuter :"
    echo -e "     ${GREEN}bash deploy-commands-freebox-local.sh${NC}"
    echo ""
    echo -e "${BLUE}📊 Résultat attendu :${NC}"
    echo "  • 47 commandes GLOBALES (serveur + MP)"
    echo "  • 46 commandes GUILD (serveur uniquement)"
    echo "  • Total : 93 commandes"
    echo ""
    echo -e "${YELLOW}⏰ Synchronisation Discord : 5-10 minutes${NC}"
    echo ""
}

# === EXÉCUTION PRINCIPALE ===

echo -e "${BLUE}🔍 Détection de la meilleure méthode...${NC}\n"

DEPLOYED=false

# Essayer méthode 1 : Local
if try_local_deploy; then
    DEPLOYED=true
fi

# Essayer méthode 2 : SSH avec mot de passe
if [[ "$DEPLOYED" == false ]]; then
    if try_ssh_deploy; then
        DEPLOYED=true
    fi
fi

# Essayer méthode 3 : SSH avec clé
if [[ "$DEPLOYED" == false ]]; then
    if try_ssh_key_deploy; then
        DEPLOYED=true
    fi
fi

# Si aucune méthode n'a fonctionné
if [[ "$DEPLOYED" == false ]]; then
    show_manual_instructions
    exit 1
fi

# Succès !
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗"
echo -e "║  🎉 DÉPLOIEMENT RÉUSSI !                             ║"
echo -e "╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Résumé :${NC}"
echo "  • Freebox : $FREEBOX_IP:$FREEBOX_PORT"
echo "  • 47 commandes GLOBALES (serveur + MP)"
echo "  • 46 commandes GUILD (serveur uniquement)"
echo "  • Total : 93 commandes disponibles"
echo ""
echo -e "${YELLOW}⏰ Les commandes seront synchronisées dans 5-10 minutes${NC}"
echo ""
echo -e "${BLUE}🔍 Pour vérifier :${NC}"
echo "  • Sur Discord : Taper / pour voir les commandes"
echo "  • Via script : node verify-commands.js"
echo ""
