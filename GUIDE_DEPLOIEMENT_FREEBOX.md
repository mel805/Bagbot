# 🚀 Guide de Déploiement des Commandes Discord sur Freebox

## ⚠️ Contexte

La Freebox (`82.67.65.98:33000`) n'est **pas accessible depuis l'environnement cloud Cursor**. Le déploiement doit être effectué soit :
1. **Depuis une machine ayant accès SSH à la Freebox** (réseau local ou VPN)
2. **Directement sur la Freebox** (connexion SSH puis exécution locale)

---

## 🎯 Solution 1 : Déploiement depuis votre machine locale (RECOMMANDÉ)

Si vous êtes sur le même réseau que la Freebox ou avez un accès SSH :

### Méthode A : Script automatique avec SSH

```bash
# Transférer le script sur votre machine locale
# Puis exécuter :
bash deploy-discord-commands-freebox.sh ssh
```

Le script va :
- ✅ Se connecter à la Freebox via SSH
- ✅ Vérifier la configuration
- ✅ Déployer les 93 commandes Discord (47 globales + 46 guild)
- ✅ Afficher un rapport de déploiement

### Méthode B : Commande SSH unique

```bash
ssh -p 33000 bagbot@82.67.65.98 'cd /home/bagbot/Bag-bot && node deploy-commands.js'
```

---

## 🎯 Solution 2 : Déploiement directement sur la Freebox

### Étape 1 : Connexion SSH à la Freebox

```bash
ssh -p 33000 bagbot@82.67.65.98
# Mot de passe : bagbot
```

### Étape 2 : Aller dans le répertoire du bot

```bash
cd /home/bagbot/Bag-bot
```

### Étape 3 : Exécuter le déploiement

**Option A : Script simplifié** (RECOMMANDÉ)

```bash
bash deploy-commands-freebox-local.sh
```

**Option B : Commande directe**

```bash
node deploy-commands.js
```

---

## 📊 Résultat attendu

Après l'exécution réussie, vous devriez voir :

```
📦 Analyse des commandes...
================================================================================
  🌐 69 (global - serveur + MP)
  🌐 daily (global - serveur + MP)
  🌐 crime (global - serveur + MP)
  ... (44 autres commandes globales)
  🏰 ban (guild - serveur uniquement)
  🏰 kick (guild - serveur uniquement)
  ... (44 autres commandes guild)

================================================================================
🌐 Commandes GLOBALES (serveur + MP): 47
🏰 Commandes GUILD (serveur uniquement): 46

🚀 Déploiement...

📤 Déploiement de 47 commandes globales...
✅ Commandes globales déployées
📤 Déploiement de 46 commandes guild...
✅ Commandes guild déployées

🎉 Déploiement terminé !

📝 Résultat:
   - 47 commandes sur serveur + MP
   - 46 commandes sur serveur uniquement
   - Total sur serveur: 93
```

---

## 🔍 Vérifier le déploiement

### Sur la Freebox

```bash
cd /home/bagbot/Bag-bot
node verify-commands.js
```

### Sur Discord

1. **Commandes serveur** : Ouvrir Discord sur votre serveur → Taper `/` → Voir les 93 commandes
2. **Commandes MP** : Envoyer un MP au bot → Taper `/` → Voir les 47 commandes globales

⏰ **Délai de synchronisation Discord** : 5-10 minutes maximum

---

## 🔧 Dépannage

### ❌ Erreur : "Cannot read property 'DISCORD_TOKEN'"

**Solution** : Vérifier le fichier `.env` sur la Freebox

```bash
ssh -p 33000 bagbot@82.67.65.98
cd /home/bagbot/Bag-bot
cat .env | grep -E "(DISCORD_TOKEN|CLIENT_ID)"
```

Les variables doivent être définies :
```
DISCORD_TOKEN=MTQxNDIxNjE3MzgwOTMwNzc4MA...
CLIENT_ID=1414216173809307780
```

### ❌ Erreur : "Connection timeout" ou "Connection refused"

**Causes possibles** :
1. La Freebox est éteinte ou hors ligne
2. Le port SSH (33000) est bloqué par un pare-feu
3. L'adresse IP a changé (vérifier sur mafreebox.freebox.fr)

**Solution** : Vérifier l'accès réseau

```bash
# Depuis votre machine locale :
ping 82.67.65.98
nc -zv 82.67.65.98 33000
```

### ❌ Les commandes n'apparaissent pas en MP

**Solutions** :
1. Attendre 5-10 minutes (synchronisation Discord)
2. Redémarrer Discord (Ctrl+R ou Cmd+R)
3. Vérifier que les commandes sont bien GLOBALES :
   ```bash
   node verify-commands.js
   ```

### ❌ Doublons de commandes

**Solution** : Nettoyer et redéployer

```bash
cd /home/bagbot/Bag-bot
node clean-all-global.js
node deploy-commands.js
```

---

## 📋 Scripts disponibles

| Script | Description | Utilisation |
|--------|-------------|-------------|
| `deploy-discord-commands-freebox.sh` | Déploiement distant (SSH) | Machine locale → Freebox |
| `deploy-commands-freebox-local.sh` | Déploiement local | Sur la Freebox directement |
| `deploy-commands.js` | Script Node.js principal | Via Node.js |
| `verify-commands.js` | Vérification des commandes | Après déploiement |
| `clean-all-global.js` | Nettoyage des commandes globales | En cas de doublons |

---

## 🎯 Récapitulatif

### ✅ Déploiement réussi si :
- 47 commandes GLOBALES déployées
- 46 commandes GUILD déployées
- Total : 93 commandes disponibles sur le serveur
- Les commandes MP fonctionnent (47 commandes)

### ⏰ Temps estimé :
- Connexion SSH : < 10 secondes
- Déploiement : 10-30 secondes
- Synchronisation Discord : 5-10 minutes

---

## 📞 Support

En cas de problème persistant :

1. **Vérifier les logs du bot** :
   ```bash
   ssh -p 33000 bagbot@82.67.65.98 'pm2 logs bagbot --lines 50'
   ```

2. **Vérifier le statut du bot** :
   ```bash
   ssh -p 33000 bagbot@82.67.65.98 'pm2 status'
   ```

3. **Redémarrer le bot** (si nécessaire) :
   ```bash
   ssh -p 33000 bagbot@82.67.65.98 'pm2 restart bagbot'
   ```

---

*Dernière mise à jour : 2025-12-22*
