# 🚀 Déploiement des Commandes Discord - Freebox

## ⚠️ Situation Actuelle

L'environnement cloud **Cursor** ne peut pas se connecter directement à votre Freebox (`82.67.65.98:33000`).

**Raison** : Restrictions réseau entre l'environnement cloud et votre Freebox.

---

## ✅ Solutions Disponibles

### 🎯 **Solution 1 : Commande SSH Unique** (LE PLUS RAPIDE)

Depuis **votre machine locale** (qui a accès à la Freebox), exécutez :

```bash
ssh -p 33000 bagbot@82.67.65.98 'cd /home/bagbot/Bag-bot && node deploy-commands.js'
```

**C'est tout !** Les commandes seront déployées en 10-30 secondes.

---

### 🎯 **Solution 2 : Script Automatisé**

#### Sur votre machine locale :

1. **Télécharger le script** :
   ```bash
   scp -P 33000 bagbot@82.67.65.98:/home/bagbot/Bag-bot/deploy-now.sh ./
   ```

2. **Exécuter** :
   ```bash
   bash deploy-now.sh
   ```

---

### 🎯 **Solution 3 : Exécution Directe sur la Freebox**

1. **Se connecter à la Freebox** :
   ```bash
   ssh -p 33000 bagbot@82.67.65.98
   ```

2. **Aller dans le répertoire** :
   ```bash
   cd /home/bagbot/Bag-bot
   ```

3. **Déployer** :
   ```bash
   node deploy-commands.js
   ```

   **OU** avec le script :
   ```bash
   bash deploy-commands-freebox-local.sh
   ```

---

## 📊 Résultat Attendu

Après un déploiement réussi :

```
📦 Analyse des commandes...
================================================================================
  🌐 69 (global - serveur + MP)
  🌐 daily (global - serveur + MP)
  ...
  🏰 ban (guild - serveur uniquement)
  🏰 kick (guild - serveur uniquement)
  ...

================================================================================
🌐 Commandes GLOBALES (serveur + MP): 47
🏰 Commandes GUILD (serveur uniquement): 46

🚀 Déploiement...

✅ Commandes globales déployées
✅ Commandes guild déployées

🎉 Déploiement terminé !

📝 Résultat:
   - 47 commandes sur serveur + MP
   - 46 commandes sur serveur uniquement
   - Total sur serveur: 93
```

---

## 📁 Scripts Créés

| Fichier | Description |
|---------|-------------|
| **`deploy-now.sh`** | Script rapide auto-détection (local/remote) |
| **`deploy-commands-freebox-local.sh`** | Script pour exécution sur la Freebox |
| **`deploy-discord-commands-freebox.sh`** | Script complet avec gestion SSH |
| **`GUIDE_DEPLOIEMENT_FREEBOX.md`** | Guide détaillé complet |

---

## 🔍 Vérification

Après le déploiement, vérifier :

```bash
ssh -p 33000 bagbot@82.67.65.98 'cd /home/bagbot/Bag-bot && node verify-commands.js'
```

---

## 🎯 Commande Recommandée (LA PLUS SIMPLE)

**Depuis votre machine locale :**

```bash
ssh -p 33000 bagbot@82.67.65.98 'cd /home/bagbot/Bag-bot && node deploy-commands.js'
```

**Durée totale : ~20 secondes** ⚡

---

## 💡 Notes Importantes

- ✅ **Port SSH** : 33000 (mis à jour)
- ✅ **IP Freebox** : 82.67.65.98
- ✅ **Utilisateur** : bagbot
- ✅ **Répertoire bot** : /home/bagbot/Bag-bot
- ⏰ **Synchronisation Discord** : 5-10 minutes après le déploiement

---

## 🆘 Dépannage

### Connexion SSH échoue

```bash
# Tester la connectivité
ping 82.67.65.98

# Tester le port SSH
nc -zv 82.67.65.98 33000

# OU avec telnet
telnet 82.67.65.98 33000
```

### Les commandes ne s'affichent pas

1. Attendre 5-10 minutes (synchronisation Discord)
2. Redémarrer Discord (`Ctrl+R` ou `Cmd+R`)
3. Vérifier le déploiement :
   ```bash
   ssh -p 33000 bagbot@82.67.65.98 'cd /home/bagbot/Bag-bot && node verify-commands.js'
   ```

### Bot offline ou en erreur

```bash
# Vérifier le statut
ssh -p 33000 bagbot@82.67.65.98 'pm2 status'

# Voir les logs
ssh -p 33000 bagbot@82.67.65.98 'pm2 logs bagbot --lines 50'

# Redémarrer si nécessaire
ssh -p 33000 bagbot@82.67.65.98 'pm2 restart bagbot'
```

---

## ✨ Résumé

**Vous ne pouvez PAS déployer depuis Cursor Cloud** ❌  
**Vous DEVEZ déployer depuis votre machine locale** ✅

**Commande la plus simple** :
```bash
ssh -p 33000 bagbot@82.67.65.98 'cd /home/bagbot/Bag-bot && node deploy-commands.js'
```

---

*Mis à jour : 2025-12-22 - Port SSH : 33000*
