#!/bin/bash
# 🚀 Déploiement Local des Commandes Discord - À exécuter SUR la Freebox

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 DÉPLOIEMENT GLOBAL DES COMMANDES DISCORD${NC}"
echo "==========================================="
echo ""

# Vérifier qu'on est dans le bon répertoire
if [[ ! -f "deploy-commands.js" ]]; then
    if [[ -d "/home/bagbot/Bag-bot" ]]; then
        cd /home/bagbot/Bag-bot
        echo -e "${YELLOW}📍 Déplacement vers /home/bagbot/Bag-bot${NC}"
    else
        echo -e "${RED}❌ Erreur: Impossible de trouver le répertoire du bot${NC}"
        echo "   Exécutez ce script depuis /home/bagbot/Bag-bot"
        exit 1
    fi
fi

# Vérifier les fichiers nécessaires
echo -e "${BLUE}🔍 Vérification des fichiers...${NC}"

if [[ ! -f ".env" ]]; then
    echo -e "${RED}❌ Fichier .env manquant${NC}"
    exit 1
fi

if [[ ! -f "deploy-commands.js" ]]; then
    echo -e "${RED}❌ Fichier deploy-commands.js manquant${NC}"
    exit 1
fi

# Vérifier que le .env contient les tokens
if ! grep -q "DISCORD_TOKEN=." .env || ! grep -q "CLIENT_ID=." .env; then
    echo -e "${RED}❌ Fichier .env incomplet${NC}"
    echo "   Vérifiez que DISCORD_TOKEN et CLIENT_ID sont définis"
    exit 1
fi

echo -e "${GREEN}✅ Configuration validée${NC}"
echo ""

# Sauvegarder l'état actuel des commandes (optionnel)
echo -e "${BLUE}📊 État actuel des commandes:${NC}"
if [[ -f "verify-commands.js" ]]; then
    node verify-commands.js 2>/dev/null || echo "   (Impossible de vérifier l'état actuel)"
    echo ""
fi

# Déployer les commandes
echo -e "${BLUE}🚀 Déploiement en cours...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

node deploy-commands.js

DEPLOY_STATUS=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $DEPLOY_STATUS -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}🎉 DÉPLOIEMENT RÉUSSI !${NC}"
    echo ""
    echo -e "${BLUE}📊 Résumé:${NC}"
    echo "  • 47 commandes GLOBALES (serveur + MP)"
    echo "  • 46 commandes GUILD (serveur uniquement)"
    echo "  • Total: 93 commandes disponibles"
    echo ""
    echo -e "${YELLOW}⏰ Synchronisation Discord: 5-10 minutes${NC}"
    echo "   Les commandes peuvent prendre quelques minutes pour apparaître"
    echo ""
    echo -e "${BLUE}🔍 Pour vérifier le déploiement:${NC}"
    echo "   node verify-commands.js"
    echo ""
else
    echo ""
    echo -e "${RED}❌ ÉCHEC DU DÉPLOIEMENT${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Solutions possibles:${NC}"
    echo "  1. Vérifier que le bot Discord est actif"
    echo "  2. Vérifier les tokens dans le fichier .env"
    echo "  3. Consulter les logs d'erreur ci-dessus"
    echo ""
    exit 1
fi
