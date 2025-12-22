#!/bin/bash

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "           🚀 REDÉMARRAGE BOT + LOGS MOT-CACHÉ"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🔑 Mot de passe: bagbot"
echo ""

ssh -p 33000 bagbot@88.174.155.230 << 'ENDSSH'

# Aller dans le dossier
cd /home/bagbot/Bag-bot

echo "📥 Récupération des modifications..."
git pull origin cursor/command-deployment-and-emoji-issue-1db6

echo ""
echo "🔄 Redémarrage du bot..."
pm2 restart bagbot

echo ""
echo "⏳ Attente (5 secondes)..."
sleep 5

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "                    ✅ BOT REDÉMARRÉ"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Logs récents:"
echo ""
pm2 logs bagbot --lines 100 --nostream

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "           🔍 LOGS EN TEMPS RÉEL - MOT-CACHÉ"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter les logs"
echo ""
sleep 2

# Logs en temps réel filtré sur MOT-CACHE
pm2 logs bagbot | grep --line-buffered "MOT-CACHE"

ENDSSH
