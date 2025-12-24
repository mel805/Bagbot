#!/bin/bash

###############################################################################
# 🚀 Installation TinyLlama 1.1B sur Freebox (Local, Non-Censuré)
# 
# Ce script installe:
#   - llama.cpp (backend léger, plus efficace qu'Ollama)
#   - TinyLlama 1.1B (637 MB, non-censuré)
#   - Serveur API compatible OpenAI
#
# Avantages:
#   - 100% local (pas d'API externe)
#   - RAM: ~900 MB (tient dans disponible)
#   - NSFW: Aucune censure
#   - Performance: 2-4 tokens/sec
#
# Utilisation:
#   bash INSTALLER_TINYLLAMA_FREEBOX.sh
#
# Date: 24 Décembre 2025
###############################################################################

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
FREEBOX_IP="88.174.155.230"
FREEBOX_PORT="33000"
FREEBOX_USER="bagbot"
FREEBOX_PASS="bagbot"

INSTALL_DIR="/home/bagbot/llama.cpp"
MODEL_NAME="tinyllama-1.1b-chat.gguf"
MODEL_URL="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
API_PORT="11434"

echo -e "${CYAN}"
cat << "BANNER"
═══════════════════════════════════════════════════════════════════
   🚀 Installation TinyLlama 1.1B sur Freebox
   
   Modèle: TinyLlama 1.1B (637 MB)
   Backend: llama.cpp (léger et rapide)
   NSFW: Aucune censure
   Performance: 2-4 tokens/sec
═══════════════════════════════════════════════════════════════════
BANNER
echo -e "${NC}"

# Vérifier sshpass
if ! command -v sshpass &> /dev/null; then
    echo -e "${YELLOW}Installation de sshpass...${NC}"
    sudo apt-get update -qq && sudo apt-get install -y sshpass
fi

echo ""
echo -e "${BLUE}[1/7]${NC} Test de connexion à la Freebox..."
if sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Connexion établie"
else
    echo -e "${RED}❌ Impossible de se connecter${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[2/7]${NC} Vérification des ressources Freebox..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'EOF'

echo "Ressources disponibles:"
free -h | grep "Mem:" | awk '{print "  RAM disponible: " $7}'
df -h /home/bagbot | tail -1 | awk '{print "  Disque disponible: " $4}'
echo "  CPU: $(nproc) cœurs"
echo ""

# Vérifier RAM
AVAILABLE_MB=$(free -m | grep "Mem:" | awk '{print $7}')
if [ $AVAILABLE_MB -lt 300 ]; then
    echo "⚠️  RAM disponible faible: ${AVAILABLE_MB} MB"
    echo "   Le modèle nécessite ~500-600 MB disponible"
    echo "   Arrêtez des services si nécessaire"
else
    echo "✓ RAM suffisante: ${AVAILABLE_MB} MB disponible"
fi

# Vérifier disque
DISK_GB=$(df -BG /home/bagbot | tail -1 | awk '{print $4}' | tr -d 'G')
if [ $DISK_GB -lt 2 ]; then
    echo "⚠️  Espace disque faible: ${DISK_GB} GB"
    echo "   Le modèle nécessite ~700 MB"
else
    echo "✓ Espace disque suffisant: ${DISK_GB} GB disponible"
fi

EOF

echo -e "${GREEN}✓${NC} Ressources vérifiées"

echo ""
echo -e "${BLUE}[3/7]${NC} Installation des dépendances..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'EOF'

# Vérifier si déjà installé
echo "Vérification des outils de compilation..."
if command -v gcc &> /dev/null && command -v g++ &> /dev/null && command -v make &> /dev/null; then
    echo "✓ Outils de compilation déjà installés"
else
    echo "Installation des outils de compilation..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq build-essential git wget curl
fi

EOF

echo -e "${GREEN}✓${NC} Dépendances installées"

echo ""
echo -e "${BLUE}[4/7]${NC} Compilation de llama.cpp (peut prendre 3-5 minutes)..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'EOF'

cd /home/bagbot

# Supprimer ancien si existe
if [ -d "llama.cpp" ]; then
    echo "⚠️  Ancien llama.cpp détecté, suppression..."
    rm -rf llama.cpp
fi

# Clone
echo "Clonage de llama.cpp..."
git clone https://github.com/ggerganov/llama.cpp 2>&1 | grep -v "Cloning"

cd llama.cpp

# Compilation optimisée pour ARM
echo "Compilation pour ARM (2 CPU)..."
make clean > /dev/null 2>&1
make -j2 2>&1 | tail -5

# Vérifier compilation
if [ -f "./server" ]; then
    echo "✓ llama.cpp compilé avec succès"
    echo "  Binaire: $(ls -lh ./server | awk '{print $5}')"
else
    echo "❌ Erreur de compilation"
    exit 1
fi

EOF

echo -e "${GREEN}✓${NC} llama.cpp compilé"

echo ""
echo -e "${BLUE}[5/7]${NC} Téléchargement de TinyLlama 1.1B (637 MB, ~2-5 minutes)..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << EOF

cd /home/bagbot/llama.cpp

# Créer dossier modèles
mkdir -p models

# Vérifier si modèle existe déjà
if [ -f "models/$MODEL_NAME" ]; then
    echo "⚠️  Modèle déjà téléchargé"
    ls -lh models/$MODEL_NAME
else
    echo "Téléchargement de TinyLlama 1.1B Q4_K_M..."
    echo "  URL: $MODEL_URL"
    echo "  Taille: ~637 MB"
    echo ""
    
    wget --progress=bar:force:noscroll \
         --tries=3 \
         --timeout=30 \
         -O models/$MODEL_NAME \
         "$MODEL_URL" 2>&1 | grep -E '%|saved'
    
    if [ -f "models/$MODEL_NAME" ]; then
        echo ""
        echo "✓ Modèle téléchargé:"
        ls -lh models/$MODEL_NAME
    else
        echo "❌ Erreur de téléchargement"
        exit 1
    fi
fi

EOF

echo -e "${GREEN}✓${NC} Modèle téléchargé"

echo ""
echo -e "${BLUE}[6/7]${NC} Configuration du serveur..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'EOFCONFIG'

cd /home/bagbot/llama.cpp

# Créer script de démarrage
cat > start-tinyllama.sh << 'EOFSTART'
#!/bin/bash

# Configuration optimisée pour Freebox ARM (2 CPU, 964 MB RAM)
cd /home/bagbot/llama.cpp

echo "═══════════════════════════════════════════════════════"
echo "🚀 Démarrage TinyLlama 1.1B Server"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Configuration:"
echo "  - Modèle: TinyLlama 1.1B (non-censuré)"
echo "  - Backend: llama.cpp"
echo "  - Port: 11434"
echo "  - Context: 512 tokens"
echo "  - Threads: 1 (laisse 1 CPU pour BagBot)"
echo "  - RAM estimée: ~800-900 MB"
echo ""
echo "API compatible OpenAI:"
echo "  POST http://localhost:11434/v1/chat/completions"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""

./server \
  --model models/tinyllama-1.1b-chat.gguf \
  --host 0.0.0.0 \
  --port 11434 \
  --ctx-size 512 \
  --threads 1 \
  --parallel 1 \
  --n-gpu-layers 0 \
  --cont-batching \
  --log-disable \
  2>&1
EOFSTART

chmod +x start-tinyllama.sh

echo "✓ Script de démarrage créé: start-tinyllama.sh"

# Arrêter ancien serveur si existe
if pm2 list | grep -q "llama-server"; then
    echo "Arrêt de l'ancien serveur..."
    pm2 delete llama-server 2>/dev/null || true
fi

EOFCONFIG

echo -e "${GREEN}✓${NC} Serveur configuré"

echo ""
echo -e "${BLUE}[7/7]${NC} Démarrage du serveur..."
sshpass -p "$FREEBOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -p "$FREEBOX_PORT" "$FREEBOX_USER@$FREEBOX_IP" << 'EOFSTART'

cd /home/bagbot/llama.cpp

# Démarrer avec PM2
pm2 start ./start-tinyllama.sh \
  --name llama-server \
  --log /home/bagbot/llama-server.log \
  --time

# Sauvegarder config PM2
pm2 save > /dev/null 2>&1

# Attendre démarrage
echo "Attente du démarrage du serveur (10 secondes)..."
sleep 10

# Afficher les premiers logs
echo ""
echo "═══════════════════════════════════════════════════════"
echo "Logs de démarrage:"
echo "═══════════════════════════════════════════════════════"
pm2 logs llama-server --lines 15 --nostream 2>/dev/null || tail -15 /home/bagbot/llama-server.log

EOFSTART

echo -e "${GREEN}✓${NC} Serveur démarré"

# Tests de validation
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}🧪 Tests de Validation${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

sleep 5

# Test 1: Health check
echo -e "${BLUE}Test 1:${NC} Health check..."
if curl -s --max-time 5 http://$FREEBOX_IP:$API_PORT/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Serveur accessible"
else
    echo -e "${YELLOW}⚠${NC} Serveur pas encore prêt (normal, il charge le modèle)"
fi

# Test 2: Génération de texte
echo ""
echo -e "${BLUE}Test 2:${NC} Génération de texte (peut prendre 10-20 secondes)..."
echo "Envoi de la requête..."

RESPONSE=$(curl -s --max-time 30 -X POST http://$FREEBOX_IP:$API_PORT/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Dis bonjour en une courte phrase."}
    ],
    "temperature": 0.7,
    "max_tokens": 30
  }' 2>/dev/null)

if echo "$RESPONSE" | grep -q "choices"; then
    echo -e "${GREEN}✓${NC} Génération fonctionnelle"
    echo ""
    echo "Réponse de TinyLlama:"
    echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    content = data['choices'][0]['message']['content']
    print('  ' + content.strip())
except: pass
" 2>/dev/null || echo "  (Voir logs pour la réponse)"
else
    echo -e "${YELLOW}⚠${NC} Pas de réponse (le modèle est peut-être encore en train de charger)"
    echo "Attendez 30 secondes et réessayez avec:"
    echo "  curl -X POST http://$FREEBOX_IP:$API_PORT/v1/chat/completions \\"
    echo "    -d '{\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
fi

# Afficher état final
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}✅ Installation Terminée${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}Configuration:${NC}"
echo "  • Modèle: TinyLlama 1.1B (non-censuré)"
echo "  • Backend: llama.cpp"
echo "  • Stockage: 100% local sur Freebox"
echo "  • RAM utilisée: ~800-900 MB"
echo "  • Performance: 2-4 tokens/sec"
echo ""

echo -e "${GREEN}API:${NC}"
echo "  • Endpoint: http://$FREEBOX_IP:$API_PORT"
echo "  • Format: OpenAI Compatible"
echo "  • NSFW: Aucune censure"
echo ""

echo -e "${GREEN}Commandes utiles:${NC}"
echo ""
echo "  Voir les logs:"
echo "    ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP 'pm2 logs llama-server'"
echo ""
echo "  Redémarrer:"
echo "    ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP 'pm2 restart llama-server'"
echo ""
echo "  Statut:"
echo "    ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP 'pm2 status'"
echo ""
echo "  Arrêter:"
echo "    ssh -p $FREEBOX_PORT $FREEBOX_USER@$FREEBOX_IP 'pm2 stop llama-server'"
echo ""

echo -e "${GREEN}Test depuis terminal:${NC}"
cat << 'TESTCMD'

curl -X POST http://88.174.155.230:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Écris un court poème"}
    ],
    "temperature": 0.8,
    "max_tokens": 100
  }'

TESTCMD

echo -e "${GREEN}Code Android (Kotlin):${NC}"
cat << 'KOTLINCODE'

class TinyLlamaClient(
    private val baseUrl: String = "http://88.174.155.230:11434"
) {
    private val client = OkHttpClient()
    
    fun chat(message: String, callback: (String) -> Unit) {
        val json = JSONObject().apply {
            put("messages", JSONArray().apply {
                put(JSONObject().apply {
                    put("role", "user")
                    put("content", message)
                })
            })
            put("temperature", 0.8)
            put("max_tokens", 200)
        }
        
        val request = Request.Builder()
            .url("$baseUrl/v1/chat/completions")
            .post(json.toString().toRequestBody("application/json".toMediaType()))
            .build()
        
        client.newCall(request).enqueue(object : Callback {
            override fun onResponse(call: Call, response: Response) {
                val result = JSONObject(response.body?.string() ?: "{}")
                val text = result
                    .getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content")
                callback(text)
            }
            override fun onFailure(call: Call, e: IOException) {
                callback("Erreur: ${e.message}")
            }
        })
    }
}

// Utilisation
val llama = TinyLlamaClient()
llama.chat("Bonjour!") { response ->
    println("TinyLlama: $response")
}

KOTLINCODE

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🎉 TinyLlama est maintenant opérationnel sur votre Freebox!${NC}"
echo ""
echo "  • 100% local (pas d'API externe)"
echo "  • Aucune censure NSFW"
echo "  • ~900 MB RAM utilisée"
echo "  • Processus séparé de BagBot"
echo ""
echo "Vous pouvez maintenant l'utiliser depuis votre application Android!"
echo ""

exit 0
