#!/bin/bash
# Script pour créer une release GitHub v5.9.14 et déclencher le build APK
# Date: 22 Décembre 2025

echo "🚀 CRÉATION RELEASE GITHUB - BAG Bot Manager v5.9.14"
echo "═══════════════════════════════════════════════════════"
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -d ".git" ]; then
    echo "❌ Erreur: Pas dans un dépôt Git"
    exit 1
fi

# Vérifier que tout est commité
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Avertissement: Il y a des modifications non commitées"
    echo ""
    echo "📝 Fichiers modifiés:"
    git status --short
    echo ""
    read -p "Voulez-vous continuer quand même? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Annulé"
        exit 1
    fi
fi

# Version
VERSION="v5.9.14"
echo "📦 Version: $VERSION"
echo ""

# Créer le tag
echo "🏷️  Création du tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION - Chat Staff Amélioré

🔔 Notifications Push
- Alertes automatiques pour nouveaux messages chat staff
- Format: 💬 Chat Staff - [Nom] : [Message]
- Smart: Pas de notification pour ses propres messages
- Son & Vibration inclus

📢 Système de Mention @
- Bouton @ pour mentionner facilement les membres
- Liste des admins en ligne
- Insertion automatique dans le message

🧹 Interface Épurée
- Retrait des commandes /actionverite et /motcache
- Bouton @ Mention ajouté
- Interface focalisée sur communication staff

🔧 Corrections Bot Discord
- Bouton Config /mot-cache corrigé
- Système mot-cache complètement revu
- Notifications lettres et gagnant fonctionnelles
- Instructions correctes pour utilisateurs

Version Code: 5914
Min SDK: 26 (Android 8.0)
Target SDK: 34 (Android 14)
"

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la création du tag"
    echo "💡 Le tag existe peut-être déjà. Utilisez: git tag -d $VERSION"
    exit 1
fi

echo "✅ Tag créé avec succès"
echo ""

# Pousser le tag sur GitHub
echo "📤 Push du tag sur GitHub..."
git push origin "$VERSION"

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du push du tag"
    echo "💡 Vérifiez vos permissions GitHub"
    exit 1
fi

echo "✅ Tag poussé sur GitHub"
echo ""

# Attendre un peu
echo "⏳ Attente de 3 secondes pour que GitHub enregistre le tag..."
sleep 3
echo ""

# Vérifier le statut du workflow
echo "🔍 Vérification du workflow GitHub Actions..."
echo ""
echo "📋 Pour voir le statut du build:"
echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
echo "💡 Le build APK sera disponible dans ~5-10 minutes"
echo ""

# Instructions
echo "═══════════════════════════════════════════════════════"
echo "✅ RELEASE CRÉÉE AVEC SUCCÈS"
echo ""
echo "📊 Prochaines étapes:"
echo ""
echo "1. 🔍 Vérifier le workflow sur GitHub Actions"
echo "   URL ci-dessus"
echo ""
echo "2. ⏰ Attendre la compilation (~5-10 minutes)"
echo ""
echo "3. 📥 Télécharger l'APK depuis:"
echo "   - Section Releases de GitHub"
echo "   - Ou artifacts du workflow Actions"
echo ""
echo "4. 📱 Distribuer l'APK aux utilisateurs"
echo ""
echo "5. 🔄 Redémarrer le bot Discord (si pas encore fait):"
echo "   ssh -p 33000 bagbot@88.174.155.230"
echo "   cd /home/bagbot/Bag-bot"
echo "   pm2 restart bagbot"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""
echo "🎉 Release $VERSION créée avec succès !"
echo ""
