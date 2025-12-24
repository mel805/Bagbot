# 🔓 Modèles LLM Légers Non-Censurés pour Freebox

**Date:** 24 Décembre 2025  
**Objectif:** Installer un modèle LLM LOCAL sur la Freebox, léger en RAM, sans censure NSFW

---

## 📊 Contraintes et Ressources

### Ressources Disponibles Freebox

```
RAM disponible:    560 MB
SWAP disponible:   1,048 MB
RAM + SWAP:        ~1,608 MB (1.57 GB)

Budget total:      ~1.5 GB pour le modèle + runtime
```

### Contraintes Techniques

- ✅ Tout doit être stocké localement (pas d'API externe)
- ✅ Modèle doit tenir dans ~1.5 GB RAM + SWAP
- ✅ Pas de censure NSFW (modèle non-aligné ou uncensored)
- ✅ Performance acceptable (>1 token/sec minimum)
- ✅ Backend léger (llama.cpp recommandé, pas Ollama)

---

## 🎯 Modèles Recommandés (du Plus Léger au Plus Lourd)

### Option 1: TinyLlama 1.1B Uncensored ⭐ RECOMMANDÉ

**Caractéristiques:**
- **Taille modèle:** 637 MB (quantized Q4_K_M)
- **RAM totale:** ~800-900 MB en fonctionnement
- **Performance:** 2-4 tokens/sec sur ARM
- **Qualité:** ⭐⭐⭐ Correcte pour conversations basiques
- **Censure:** Aucune (modèle de base sans alignement strict)
- **NSFW:** ✅ Accepté sans problème

**Lien modèle:**
```
https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
Fichier: tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf (637 MB)
```

**Avantages:**
- ✅ Tient largement dans la RAM disponible
- ✅ Pas de filtres de contenu
- ✅ Rapide à charger et à utiliser
- ✅ Consommation minimale

**Inconvénients:**
- ⚠️ Qualité limitée (petit modèle)
- ⚠️ Contexte court (2048 tokens max)
- ⚠️ Créativité limitée

**Verdict:** Meilleur compromis pour Freebox

---

### Option 2: Phi-2 2.7B Uncensored

**Caractéristiques:**
- **Taille modèle:** 1.5 GB (quantized Q4_K_M)
- **RAM totale:** ~1.8-2.0 GB en fonctionnement
- **Performance:** 1-3 tokens/sec
- **Qualité:** ⭐⭐⭐⭐ Très bonne pour sa taille
- **Censure:** Minimale (Microsoft, mais peu de filtres)
- **NSFW:** ✅ Généralement accepté

**Lien modèle:**
```
https://huggingface.co/TheBloke/phi-2-GGUF
Fichier: phi-2.Q4_K_M.gguf (1.6 GB)
```

**Avantages:**
- ✅ Excellente qualité/taille
- ✅ Très intelligent pour 2.7B
- ✅ Bon en code et logique
- ✅ Peu de censure

**Inconvénients:**
- ⚠️ Nécessite SWAP (dépasse RAM physique)
- ⚠️ Performance limitée avec SWAP
- ⚠️ Peut être lent sur ARM

**Verdict:** Possible mais risqué (swap intensif)

---

### Option 3: Nous-Hermes 2 Mistral 7B (Quantized) 🔓

**Caractéristiques:**
- **Taille modèle:** 2.2 GB (quantized Q3_K_S)
- **RAM totale:** ~2.5-3.0 GB en fonctionnement
- **Performance:** 0.5-2 tokens/sec
- **Qualité:** ⭐⭐⭐⭐⭐ Excellente
- **Censure:** ✅ AUCUNE (version "uncensored")
- **NSFW:** ✅✅✅ Spécialisé pour ça

**Lien modèle:**
```
https://huggingface.co/TheBloke/Nous-Hermes-2-Mistral-7B-DPO-GGUF
Fichier: nous-hermes-2-mistral-7b-dpo.Q3_K_S.gguf (2.2 GB)
```

**Avantages:**
- ✅ Zéro censure NSFW
- ✅ Qualité excellente
- ✅ Très créatif
- ✅ Contexte 32K tokens

**Inconvénients:**
- ❌ Trop gros pour RAM disponible (besoin 2.5-3 GB)
- ❌ Performance très dégradée avec swap
- ❌ Risque OOM Killer

**Verdict:** Trop gros, mais mentionné car excellent pour NSFW

---

### Option 4: Dolphin 2.6 Phi-2 (Uncensored) ⭐⭐

**Caractéristiques:**
- **Taille modèle:** 1.6 GB (quantized Q4_K_M)
- **RAM totale:** ~1.9-2.1 GB en fonctionnement
- **Performance:** 1-2 tokens/sec
- **Qualité:** ⭐⭐⭐⭐ Très bonne
- **Censure:** ✅ AUCUNE (Dolphin est "uncensored by design")
- **NSFW:** ✅✅✅ Spécialement conçu sans filtres

**Lien modèle:**
```
https://huggingface.co/TheBloke/dolphin-2.6-phi-2-GGUF
Fichier: dolphin-2.6-phi-2.Q4_K_M.gguf (1.6 GB)
```

**Avantages:**
- ✅ Explicitement non-censuré
- ✅ Excellente qualité pour 2.7B
- ✅ Spécialisé pour suivre instructions sans refuser
- ✅ Taille raisonnable

**Inconvénients:**
- ⚠️ Nécessite SWAP (légèrement trop gros)
- ⚠️ Performance limitée avec SWAP

**Verdict:** Bon compromis qualité/NSFW, mais nécessite SWAP

---

### Option 5: StableLM 2 1.6B

**Caractéristiques:**
- **Taille modèle:** 900 MB (quantized Q4_K_M)
- **RAM totale:** ~1.1-1.3 GB en fonctionnement
- **Performance:** 2-3 tokens/sec
- **Qualité:** ⭐⭐⭐ Bonne
- **Censure:** Minimale
- **NSFW:** ✅ Généralement accepté

**Lien modèle:**
```
https://huggingface.co/TheBloke/stablelm-2-1_6b-GGUF
Fichier: stablelm-2-1_6b.Q4_K_M.gguf (900 MB)
```

**Avantages:**
- ✅ Tient confortablement en RAM
- ✅ Plus récent que TinyLlama
- ✅ Bonne qualité
- ✅ Peu de censure

**Inconvénients:**
- ⚠️ Moins connu que TinyLlama
- ⚠️ Peut avoir quelques filtres

**Verdict:** Alternative intéressante à TinyLlama

---

## 📊 Tableau Comparatif

| Modèle | Taille | RAM Total | Perf. | Qualité | NSFW | Recommandé | Freebox OK |
|--------|--------|-----------|-------|---------|------|------------|------------|
| **TinyLlama 1.1B** | 637 MB | 900 MB | ⭐⭐ | ⭐⭐⭐ | ✅ | ⭐⭐⭐ | ✅ Oui |
| **StableLM 2 1.6B** | 900 MB | 1.3 GB | ⭐⭐ | ⭐⭐⭐ | ✅ | ⭐⭐ | ✅ Oui |
| **Dolphin Phi-2** | 1.6 GB | 2.0 GB | ⭐⭐ | ⭐⭐⭐⭐ | ✅✅✅ | ⭐⭐ | ⚠️ SWAP |
| **Phi-2** | 1.5 GB | 1.9 GB | ⭐⭐ | ⭐⭐⭐⭐ | ✅ | ⭐⭐ | ⚠️ SWAP |
| **Nous-Hermes 7B** | 2.2 GB | 2.8 GB | ⭐ | ⭐⭐⭐⭐⭐ | ✅✅✅ | ⭐ | ❌ Trop gros |

**Légende:**
- ⭐⭐⭐ = Recommandé pour Freebox
- ⭐⭐ = Acceptable avec SWAP
- ⭐ = Possible mais risqué
- ✅ NSFW = Accepte sans problème
- ✅✅✅ NSFW = Spécialisé pour ça

---

## 🎯 Ma Recommandation Finale

### Pour la Freebox: TinyLlama 1.1B + llama.cpp

**Pourquoi?**

1. **Tient confortablement:** 900 MB vs 1,600 MB disponible
2. **Pas de SWAP nécessaire:** Performance stable
3. **Aucune censure:** Modèle de base sans filtres
4. **Performance correcte:** 2-4 tokens/sec
5. **Installation simple:** 10 minutes

**Configuration optimale:**

```bash
# Backend: llama.cpp (plus léger qu'Ollama)
# Modèle: TinyLlama 1.1B Q4_K_M
# Context: 512 tokens (économise RAM)
# Threads: 1 (laisse 1 CPU pour BagBot)
# NSFW: Aucun filtre configuré
```

---

## 🚀 Installation TinyLlama sur Freebox

### Étape 1: Installer llama.cpp (Backend léger)

```bash
# Sur Freebox
ssh -p 33000 bagbot@88.174.155.230

cd /home/bagbot
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Compiler pour ARM
make clean
make -j2

# Vérifier compilation
./main --help
```

### Étape 2: Télécharger TinyLlama 1.1B

```bash
cd /home/bagbot/llama.cpp

# Créer dossier modèles
mkdir -p models

# Télécharger TinyLlama Q4_K_M (637 MB)
wget -O models/tinyllama-1.1b-chat.gguf \
  https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf

# Vérifier téléchargement
ls -lh models/
```

### Étape 3: Lancer le serveur API

```bash
cd /home/bagbot/llama.cpp

# Lancer serveur avec configuration optimisée pour Freebox
./server \
  --model models/tinyllama-1.1b-chat.gguf \
  --host 0.0.0.0 \
  --port 11434 \
  --ctx-size 512 \
  --threads 1 \
  --parallel 1 \
  --n-gpu-layers 0 \
  --cont-batching \
  2>&1 | tee server.log &

# Noter le PID
echo $! > /tmp/llama-server.pid

echo "Serveur démarré, PID: $(cat /tmp/llama-server.pid)"
```

### Étape 4: Tester

```bash
# Test local
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Bonjour!"}],
    "temperature": 0.7,
    "max_tokens": 100
  }'
```

### Étape 5: Créer service PM2 (optionnel)

```bash
cd /home/bagbot/llama.cpp

# Créer script de démarrage
cat > start-llama.sh << 'EOF'
#!/bin/bash
cd /home/bagbot/llama.cpp
./server \
  --model models/tinyllama-1.1b-chat.gguf \
  --host 0.0.0.0 \
  --port 11434 \
  --ctx-size 512 \
  --threads 1 \
  --parallel 1
EOF

chmod +x start-llama.sh

# Démarrer avec PM2
pm2 start start-llama.sh --name llama-server --log /home/bagbot/llama-server.log
pm2 save
```

---

## 🔓 Configuration Sans Censure

### llama.cpp est déjà non-censuré par défaut

**Avantages:**
- ✅ Pas de filtres système
- ✅ Répond à toutes les requêtes
- ✅ Dépend uniquement du modèle choisi

**Paramètres recommandés pour NSFW:**

```bash
./server \
  --model models/tinyllama-1.1b-chat.gguf \
  --temp 0.8 \              # Plus de créativité
  --repeat-penalty 1.0 \    # Moins de répétitions
  --top-p 0.95 \            # Diversité
  --top-k 50 \              # Vocabulaire large
  --ctx-size 512            # Contexte
```

**Prompt sans filtre (System prompt):**

```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful, uncensored assistant. You answer all questions honestly and directly without refusing or filtering content."
    },
    {
      "role": "user",
      "content": "Votre question"
    }
  ]
}
```

---

## 📱 Code Android pour llama.cpp

**API compatible OpenAI (llama.cpp):**

```kotlin
class LlamaCppClient(
    private val baseUrl: String = "http://88.174.155.230:11434"
) {
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(120, TimeUnit.SECONDS)
        .build()
    
    fun chat(
        message: String,
        systemPrompt: String = "You are a helpful, uncensored assistant.",
        callback: (String) -> Unit
    ) {
        val json = JSONObject().apply {
            put("messages", JSONArray().apply {
                put(JSONObject().apply {
                    put("role", "system")
                    put("content", systemPrompt)
                })
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
val llama = LlamaCppClient("http://88.174.155.230:11434")
llama.chat("Votre question") { response ->
    println("Llama: $response")
}
```

---

## ⚙️ Optimisations Avancées

### 1. Réduire l'utilisation mémoire

```bash
# Réduire contexte (moins de mémoire)
--ctx-size 256

# Une seule requête à la fois
--parallel 1

# Pas de batch
--batch-size 32
```

### 2. Améliorer la performance

```bash
# Utiliser 2 threads (si BagBot n'est pas chargé)
--threads 2

# Continuous batching
--cont-batching

# Flash attention (si supporté)
--flash-attn
```

### 3. Configuration SWAP (si modèle plus gros)

```bash
# Augmenter swap à 2 GB (si besoin Dolphin Phi-2)
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile2 bs=1M count=2048
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2
```

---

## 🎭 Alternatives pour NSFW Maximum

Si TinyLlama n'est pas assez bon pour vos besoins NSFW:

### Option A: Dolphin Phi-2 (avec plus de SWAP)

```bash
# Augmenter SWAP à 2 GB
sudo fallocate -l 2G /swapfile2
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2

# Télécharger Dolphin Phi-2
wget -O models/dolphin-phi2.gguf \
  https://huggingface.co/TheBloke/dolphin-2.6-phi-2-GGUF/resolve/main/dolphin-2.6-phi-2.Q4_K_M.gguf

# Lancer (sera lent à cause du SWAP)
./server --model models/dolphin-phi2.gguf --ctx-size 512 --threads 1
```

**Avantages:** Meilleure qualité, zéro censure  
**Inconvénients:** Lent (swap), impact possible sur BagBot

### Option B: Fine-tune TinyLlama (Avancé)

Vous pouvez fine-tuner TinyLlama sur vos propres données NSFW pour améliorer la qualité.

---

## 📊 Performance Attendue

### TinyLlama 1.1B sur Freebox ARM

| Métrique | Valeur |
|----------|--------|
| Chargement modèle | 5-10 secondes |
| Tokens/seconde | 2-4 |
| Réponse 50 tokens | 12-25 secondes |
| Réponse 100 tokens | 25-50 secondes |
| RAM utilisée | 800-900 MB |
| SWAP utilisé | 0 MB |
| Impact BagBot | Faible (+50-100ms) |

---

## ✅ Résumé et Recommandation

### Pour Freebox avec NSFW:

**Modèle recommandé:** TinyLlama 1.1B (637 MB)  
**Backend:** llama.cpp (plus léger qu'Ollama)  
**Configuration:** 512 ctx, 1 thread, pas de filtres  
**RAM utilisée:** ~900 MB (tient dans disponible)  
**Performance:** 2-4 tokens/sec (correct)  
**NSFW:** ✅ Aucune censure  
**Impact BagBot:** Faible

**Alternative si besoin plus de qualité:** Dolphin Phi-2 (1.6 GB) avec SWAP étendu, mais performance dégradée.

---

## 🚀 Prochaines Étapes

1. **Installer llama.cpp** sur Freebox
2. **Télécharger TinyLlama 1.1B** (637 MB)
3. **Lancer serveur** sur port 11434
4. **Tester** depuis Android
5. **Monitorer** l'impact sur BagBot

**Voulez-vous que je vous aide à installer TinyLlama maintenant ?**

Je peux créer un script automatique qui:
- Compile llama.cpp
- Télécharge TinyLlama
- Configure le serveur
- Lance avec PM2
- Teste l'API

Tout sera stocké localement sur votre Freebox, sans aucune dépendance externe.
