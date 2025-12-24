#!/bin/bash
# Script pour redémarrer TinyLlama sur la Freebox

echo "════════════════════════════════════════════════════════════"
echo "🔧 REDÉMARRAGE DU SERVEUR TINYLLAMA SUR FREEBOX"
echo "════════════════════════════════════════════════════════════"
echo ""

echo "📡 Connexion à la Freebox..."
sshpass -p 'root bagbot' ssh -o StrictHostKeyChecking=no root@88.174.155.230 << 'EOF'

echo "✅ Connecté à la Freebox"
echo ""

echo "1️⃣ Vérification du status Ollama..."
systemctl status ollama | head -10
echo ""

echo "2️⃣ Redémarrage d'Ollama..."
systemctl restart ollama
sleep 5
echo ""

echo "3️⃣ Vérification après redémarrage..."
systemctl status ollama | head -10
echo ""

echo "4️⃣ Test de l'API Ollama en local..."
curl -s http://localhost:11434/api/tags | head -20
echo ""

echo "5️⃣ Vérification du port 11434..."
netstat -tlnp | grep 11434
echo ""

echo "✅ Redémarrage terminé!"

EOF

echo ""
echo "════════════════════════════════════════════════════════════"
echo "🎉 TERMINÉ!"
echo "════════════════════════════════════════════════════════════"
