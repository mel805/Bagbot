#!/bin/bash

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "           🚀 DÉPLOIEMENT BOT DISCORD - v5.9.15"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Ce script va:"
echo "   1. Se connecter à la Freebox"
echo "   2. Récupérer les dernières modifications"
echo "   3. Redémarrer le bot"
echo "   4. Afficher les logs"
echo ""
echo "🔑 Mot de passe: bagbot"
echo ""
echo "⏳ Connexion en cours..."
echo ""

ssh -p 33000 bagbot@88.174.155.230 << 'EOF'
cd /home/bagbot/Bag-bot

echo "📥 Récupération des modifications..."
git pull origin cursor/command-deployment-and-emoji-issue-1db6

echo ""
echo "🔄 Redémarrage du bot..."
pm2 restart bagbot

echo ""
echo "⏳ Attente démarrage (3 secondes)..."
sleep 3

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "                    ✅ BOT REDÉMARRÉ"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Logs récents:"
echo ""
pm2 logs bagbot --lines 30 --nostream

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "                 📝 PROCHAINES ÉTAPES"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "1️⃣  Observer logs mot-caché:"
echo "    pm2 logs bagbot | grep 'MOT-CACHE'"
echo ""
echo "2️⃣  Sur Discord:"
echo "    /mot-cache"
echo "    Cliquer '⚙️ Config' (devrait fonctionner!)"
echo "    ✅ Activer le jeu"
echo "    📝 Mot: CALIN"
echo "    🎲 Probabilité: 50%"
echo ""
echo "3️⃣  Envoyer 10 messages >15 caractères"
echo ""
echo "4️⃣  Observer emoji 🔍 et logs"
echo ""
echo "5️⃣  APK v5.9.15 sera prêt dans ~5 minutes:"
echo "    https://github.com/mel805/Bagbot/releases/tag/v5.9.15"
echo ""
echo "════════════════════════════════════════════════════════════════"
EOF

echo ""
echo "✅ Script terminé!"
echo ""
