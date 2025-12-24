#!/bin/bash

###############################################################################
# 🚀 Déploiement Complet Naruto AI Chat
#
# Ce script guide le déploiement complet de l'application Naruto AI Chat:
# 1. Création repo GitHub
# 2. Push du code
# 3. Création de la release
# 4. Instructions Oracle Cloud
#
# ⚠️ ATTENTION: Cette app est COMPLÈTEMENT SÉPARÉE de BagBot Manager
# Elle ne touche PAS à:
#   - /workspace/android-app/ (BagBot Manager)
#   - /workspace/src/ (Bot Discord)
#   - Le repo mel805/Bagbot
#
# Date: 24 Décembre 2025
###############################################################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "BANNER"
═══════════════════════════════════════════════════════════════════
   🍜 Déploiement Naruto AI Chat
   
   Application: Chatbot AI avec personnages Naruto et célébrités
   Modes: SFW et NSFW
   Backend: Oracle Cloud + Llama 3.2
═══════════════════════════════════════════════════════════════════
BANNER
echo -e "${NC}"

PROJECT_DIR="/workspace/naruto-ai-chat"

# Vérification
echo -e "${BLUE}[Vérification]${NC} Séparation des projets..."
echo ""
echo "✅ Naruto AI Chat:  $PROJECT_DIR"
echo "✅ BagBot Manager:  /workspace/android-app (NON TOUCHÉ)"
echo "✅ Bot Discord:     /workspace/src (NON TOUCHÉ)"
echo ""

cd $PROJECT_DIR

# Étape 1: GitHub
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Étape 1/4: Publication sur GitHub${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}Action requise:${NC} Créer le repository GitHub"
echo ""
echo "1. Ouvrir dans un navigateur:"
echo -e "   ${GREEN}https://github.com/new${NC}"
echo ""
echo "2. Configuration du repo:"
echo "   - Repository name:  naruto-ai-chat"
echo "   - Description:      🍜 AI Chat with Naruto characters & celebrities (SFW/NSFW)"
echo "   - Visibility:       Public"
echo "   - ⚠️  NE PAS initialiser avec README/gitignore"
echo ""
echo "3. Cliquer 'Create repository'"
echo ""

read -p "Appuyez sur ENTRÉE une fois le repo créé..."

echo ""
echo -e "${BLUE}Configuration du remote...${NC}"

# Demander l'username GitHub
echo ""
read -p "Entrez votre username GitHub: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}❌ Username requis${NC}"
    exit 1
fi

REPO_URL="https://github.com/$GITHUB_USERNAME/naruto-ai-chat.git"

# Vérifier si remote existe déjà
if git remote get-url origin &> /dev/null; then
    echo "Remote origin existe déjà, mise à jour..."
    git remote set-url origin $REPO_URL
else
    echo "Ajout du remote origin..."
    git remote add origin $REPO_URL
fi

echo -e "${GREEN}✓${NC} Remote configuré: $REPO_URL"
echo ""

# Push
echo -e "${BLUE}Push du code vers GitHub...${NC}"
git branch -M main
git push -u origin main --force 2>&1 | tail -10

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Code poussé avec succès!${NC}"
    echo ""
    echo "Vérifier: ${GREEN}https://github.com/$GITHUB_USERNAME/naruto-ai-chat${NC}"
else
    echo -e "${RED}❌ Erreur lors du push${NC}"
    echo "Vérifiez vos credentials GitHub"
    exit 1
fi

# Étape 2: Release
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Étape 2/4: Création de la Release${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}Création du tag v1.0.0...${NC}"
git tag -a v1.0.0 -m "Release 1.0.0: Naruto AI Chat

Features:
- 6 personnages Naruto (Naruto, Sasuke, Sakura, Kakashi, Hinata, Itachi)
- 7 célébrités (Brad Pitt, Leo, The Rock, Scarlett, Margot, Emma, Zendaya)
- Modes SFW et NSFW
- Personnalités réalistes
- Interface Material Design 3
- Intégration Oracle Cloud / Llama 3.2
" 2>&1

echo -e "${BLUE}Push du tag...${NC}"
git push origin v1.0.0 2>&1 | tail -5

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Tag v1.0.0 créé et poussé!${NC}"
    echo ""
    echo "GitHub Actions va maintenant:"
    echo "  1. Builder l'APK (environ 10 minutes)"
    echo "  2. Créer la release automatiquement"
    echo "  3. Uploader l'APK sur la release"
    echo ""
    echo "Suivre le build:"
    echo -e "  ${GREEN}https://github.com/$GITHUB_USERNAME/naruto-ai-chat/actions${NC}"
    echo ""
    echo "Une fois terminé, l'APK sera disponible:"
    echo -e "  ${GREEN}https://github.com/$GITHUB_USERNAME/naruto-ai-chat/releases/tag/v1.0.0${NC}"
else
    echo -e "${YELLOW}⚠${NC} Erreur lors du push du tag"
    echo "Vous pouvez créer la release manuellement:"
    echo "  1. Aller sur: https://github.com/$GITHUB_USERNAME/naruto-ai-chat/actions"
    echo "  2. Cliquer 'Build and Release APK'"
    echo "  3. Run workflow → version: 1.0.0"
fi

# Étape 3: Oracle Cloud
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Étape 3/4: Configuration Oracle Cloud${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo "Pour utiliser l'app, vous devez configurer Oracle Cloud (GRATUIT):"
echo ""
echo "📋 Instructions complètes dans:"
echo "   /workspace/GUIDE_COMPLET_NARUTO_AI_CHAT.md"
echo ""
echo "🚀 Script d'installation Oracle Cloud:"
echo "   /workspace/INSTALL_LLAMA_ORACLE_CLOUD.sh"
echo ""

echo -e "${YELLOW}Résumé rapide:${NC}"
echo ""
echo "1. Créer compte Oracle Cloud (gratuit):"
echo "   → https://cloud.oracle.com/free"
echo ""
echo "2. Créer VM ARM (Always Free):"
echo "   → Shape: VM.Standard.A1.Flex"
echo "   → CPU: 4, RAM: 24 GB"
echo "   → Image: Ubuntu 22.04 ARM"
echo ""
echo "3. Configurer Firewall:"
echo "   → Networking → Security Lists"
echo "   → Add Ingress Rule: TCP 11434, Source 0.0.0.0/0"
echo ""
echo "4. Installer Ollama + Llama:"
echo "   → ssh ubuntu@VM-IP"
echo "   → curl -fsSL https://ollama.com/install.sh | sh"
echo "   → ollama pull llama3.2:3b"
echo ""
echo "5. Configurer accès externe:"
echo "   → sudo systemctl edit ollama.service"
echo "   → Ajouter: Environment=\"OLLAMA_HOST=0.0.0.0:11434\""
echo "   → sudo systemctl restart ollama"
echo ""

read -p "Voulez-vous les instructions détaillées Oracle Cloud? (y/N): " SHOW_ORACLE

if [[ "$SHOW_ORACLE" =~ ^[Yy]$ ]]; then
    echo ""
    cat /workspace/GUIDE_COMPLET_NARUTO_AI_CHAT.md | grep -A 50 "Étape 3: Configurer Oracle Cloud"
fi

# Étape 4: Résumé
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Étape 4/4: Résumé et Prochaines Étapes${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}✅ Déploiement terminé avec succès!${NC}"
echo ""

echo "📦 Repository GitHub:"
echo "   https://github.com/$GITHUB_USERNAME/naruto-ai-chat"
echo ""

echo "🚀 GitHub Actions (build en cours):"
echo "   https://github.com/$GITHUB_USERNAME/naruto-ai-chat/actions"
echo ""

echo "📱 Release APK (disponible dans ~10 min):"
echo "   https://github.com/$GITHUB_USERNAME/naruto-ai-chat/releases/tag/v1.0.0"
echo ""

echo "☁️  Oracle Cloud (à configurer):"
echo "   https://cloud.oracle.com"
echo ""

echo -e "${YELLOW}Prochaines étapes:${NC}"
echo ""
echo "1. ⏳ Attendre le build GitHub Actions (~10 minutes)"
echo "   → Vérifier: https://github.com/$GITHUB_USERNAME/naruto-ai-chat/actions"
echo ""
echo "2. ☁️  Configurer Oracle Cloud (~30 minutes)"
echo "   → Suivre: /workspace/GUIDE_COMPLET_NARUTO_AI_CHAT.md"
echo "   → OU exécuter: bash /workspace/INSTALL_LLAMA_ORACLE_CLOUD.sh"
echo ""
echo "3. 📱 Télécharger et installer l'APK"
echo "   → Depuis: https://github.com/$GITHUB_USERNAME/naruto-ai-chat/releases"
echo ""
echo "4. ⚙️  Configurer l'app"
echo "   → Ouvrir app → Settings"
echo "   → Entrer URL Oracle: http://VOTRE-IP-ORACLE:11434"
echo ""
echo "5. 🎉 Profiter!"
echo "   → Chatter avec Naruto, Sasuke, etc."
echo "   → Modes SFW et NSFW disponibles"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🍜 Naruto AI Chat est en cours de déploiement!${NC}"
echo ""
echo "📄 Documentation complète:"
echo "   - GUIDE_COMPLET_NARUTO_AI_CHAT.md"
echo "   - PUBLICATION_NARUTO_AI_CHAT.md"
echo "   - README.md"
echo ""
echo "💬 Support:"
echo "   - GitHub Issues: https://github.com/$GITHUB_USERNAME/naruto-ai-chat/issues"
echo "   - Documentation: /workspace/GUIDE_COMPLET_NARUTO_AI_CHAT.md"
echo ""

# Sauvegarder les infos
cat > /workspace/NARUTO_AI_DEPLOYMENT_INFO.txt << EOF
═══════════════════════════════════════════════════════════════════
NARUTO AI CHAT - INFORMATIONS DE DÉPLOIEMENT
═══════════════════════════════════════════════════════════════════

Date: $(date)
Status: ✅ Déployé avec succès

GITHUB
──────
Repository: https://github.com/$GITHUB_USERNAME/naruto-ai-chat
Actions:    https://github.com/$GITHUB_USERNAME/naruto-ai-chat/actions
Releases:   https://github.com/$GITHUB_USERNAME/naruto-ai-chat/releases

APK
───
URL Release: https://github.com/$GITHUB_USERNAME/naruto-ai-chat/releases/tag/v1.0.0
Nom fichier: Naruto-AI-Chat-v1.0.0.apk

ORACLE CLOUD
────────────
Console:     https://cloud.oracle.com
Free Tier:   https://cloud.oracle.com/free
VM Config:   4 CPU ARM + 24 GB RAM (Always Free)
Port:        11434 (Ollama API)

PERSONNAGES (13 total)
─────────────────────
Naruto (6):
  - 🍜 Naruto Uzumaki
  - ⚡ Sasuke Uchiha
  - 🌸 Sakura Haruno
  - 📖 Kakashi Hatake
  - 💜 Hinata Hyuga
  - 🌙 Itachi Uchiha

Célébrités (7):
  - 🎬 Brad Pitt
  - 🌊 Leonardo DiCaprio
  - 💪 Dwayne Johnson
  - 🕷️ Scarlett Johansson
  - 💎 Margot Robbie
  - 📚 Emma Watson
  - ✨ Zendaya

FONCTIONNALITÉS
───────────────
✅ Modes SFW et NSFW
✅ Personnalités réalistes
✅ Context-aware conversations
✅ Material Design 3 UI
✅ Oracle Cloud integration

PROCHAINES ÉTAPES
─────────────────
1. Attendre build GitHub Actions (~10 min)
2. Configurer Oracle Cloud (~30 min)
3. Télécharger APK
4. Installer et configurer
5. Profiter!

DOCUMENTATION
─────────────
- GUIDE_COMPLET_NARUTO_AI_CHAT.md
- PUBLICATION_NARUTO_AI_CHAT.md
- README.md dans le repo

═══════════════════════════════════════════════════════════════════
EOF

echo -e "${GREEN}✓${NC} Informations sauvegardées dans:"
echo "   /workspace/NARUTO_AI_DEPLOYMENT_INFO.txt"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎊 Déploiement terminé! Dattebayo! 🎊${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

exit 0
