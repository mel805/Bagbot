#!/bin/bash

###############################################################################
# Installation TinyLlama sur Freebox - 100% Gratuit et Illimité
#
# Caractéristiques:
# - Modèle: TinyLlama 1.1B (637 MB)
# - RAM: ~900 MB (552 MB + swap)
# - Gratuit: Oui, 100% local
# - Illimité: Oui, aucune limite de requêtes
# - Uncensored: Oui, pas de filtre
# - Backend: llama.cpp (optimisé)
#
# Date: 24 Décembre 2025
###############################################################################

set -e

FREEBOX_IP="88.174.155.230"
FREEBOX_PORT="33000"
FREEBOX_USER="bagbot"
FREEBOX_PASS="bagbot"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🍜 Installation TinyLlama sur Freebox${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}✓${NC} Freebox: $FREEBOX_IP:$FREEBOX_PORT"
echo -e "${GREEN}✓${NC} Modèle: TinyLlama 1.1B (637 MB)"
echo -e "${GREEN}✓${NC} RAM: 552 MB + 1 GB SWAP"
echo -e "${GREEN}✓${NC} Gratuit: Oui"
echo -e "${GREEN}✓${NC} Illimité: Oui"
echo ""

# Étape 1: Compiler llama.cpp
echo -e "${YELLOW}[1/6]${NC} Compilation llama.cpp..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP << 'ENDSSH'
set -e

cd ~

# Cloner llama.cpp si pas déjà fait
if [ ! -d "llama.cpp" ]; then
    echo "Clonage llama.cpp..."
    git clone https://github.com/ggerganov/llama.cpp.git
fi

cd llama.cpp

# Compiler (optimisé pour ARM)
echo "Compilation..."
make clean 2>/dev/null || true
make -j2

echo "✓ llama.cpp compilé"
ENDSSH

echo -e "${GREEN}✓${NC} llama.cpp compilé"
echo ""

# Étape 2: Télécharger TinyLlama
echo -e "${YELLOW}[2/6]${NC} Téléchargement TinyLlama 1.1B..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP << 'ENDSSH'
set -e

cd ~/llama.cpp

# Créer dossier models
mkdir -p models

cd models

# Télécharger TinyLlama Q4_K_M (637 MB - bon équilibre qualité/taille)
if [ ! -f "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" ]; then
    echo "Téléchargement TinyLlama (637 MB)..."
    curl -L -o tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf \
        "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
    echo "✓ TinyLlama téléchargé"
else
    echo "✓ TinyLlama déjà téléchargé"
fi
ENDSSH

echo -e "${GREEN}✓${NC} TinyLlama téléchargé"
echo ""

# Étape 3: Créer script de démarrage
echo -e "${YELLOW}[3/6]${NC} Création du script de démarrage..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP << 'ENDSSH'
set -e

cat > ~/llama.cpp/start-server.sh << 'EOF'
#!/bin/bash

# TinyLlama Chat Server pour Naruto AI Chat
# Port: 8080
# Format: OpenAI-compatible API

cd ~/llama.cpp

# Démarrer le serveur
./llama-server \
  --model models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf \
  --host 0.0.0.0 \
  --port 8080 \
  --n-gpu-layers 0 \
  --ctx-size 2048 \
  --threads 2 \
  --batch-size 512 \
  --memory-f32 \
  --log-disable \
  --verbose
EOF

chmod +x ~/llama.cpp/start-server.sh
echo "✓ Script créé"
ENDSSH

echo -e "${GREEN}✓${NC} Script de démarrage créé"
echo ""

# Étape 4: Configurer PM2
echo -e "${YELLOW}[4/6]${NC} Configuration PM2..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP << 'ENDSSH'
set -e

# Vérifier si PM2 est installé
if ! command -v pm2 &> /dev/null; then
    echo "Installation PM2..."
    npm install -g pm2
fi

# Supprimer ancienne instance si existe
pm2 delete tinyllama 2>/dev/null || true

# Démarrer avec PM2
pm2 start ~/llama.cpp/start-server.sh --name tinyllama --time

# Sauvegarder config
pm2 save

# Auto-démarrage
pm2 startup systemd -u bagbot --hp /home/bagbot 2>/dev/null || true

echo "✓ PM2 configuré"
ENDSSH

echo -e "${GREEN}✓${NC} PM2 configuré"
echo ""

# Étape 5: Attendre démarrage
echo -e "${YELLOW}[5/6]${NC} Démarrage du serveur (peut prendre 30 secondes)..."
sleep 30

# Étape 6: Tester
echo -e "${YELLOW}[6/6]${NC} Test du serveur..."
TEST_RESULT=$(sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP << 'ENDSSH'
curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinyllama",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }' | grep -q "choices" && echo "OK" || echo "FAIL"
ENDSSH
)

if [ "$TEST_RESULT" = "OK" ]; then
    echo -e "${GREEN}✓${NC} Serveur fonctionne!"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Installation terminée avec succès!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "🔗 URL pour l'app: http://$FREEBOX_IP:8080"
    echo ""
    echo "📋 Commandes utiles:"
    echo "  pm2 status         - Voir status"
    echo "  pm2 logs tinyllama - Voir logs"
    echo "  pm2 restart tinyllama - Redémarrer"
    echo "  pm2 stop tinyllama - Arrêter"
    echo ""
    echo "✨ Caractéristiques:"
    echo "  - Gratuit: 100%"
    echo "  - Illimité: Oui"
    echo "  - Uncensored: Oui"
    echo "  - Local: Oui"
    echo ""
else
    echo -e "${YELLOW}⚠${NC} Le serveur démarre encore, attendre 1 minute"
    echo ""
    echo "Vérifier avec:"
    echo "  ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP"
    echo "  pm2 logs tinyllama"
fi

exit 0
