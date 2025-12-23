# Changelog v5.9.15 - Améliorations Mot-Caché

**Date de release** : 22 Décembre 2025  
**Type** : Feature Update

---

## 🆕 Nouvelles Fonctionnalités

### 🔍 Système Mot-Caché - Améliorations Majeures

#### 1. Mode de Jeu
- **Mode Quotidien (📅)** : Distribution automatique de X lettres par jour
  - Configurable via `lettersPerDay` (1-20 lettres)
  - Planning automatique (à implémenter avec CRON)
  
- **Mode Probabilité (🎲)** : Chance aléatoire sur chaque message
  - Configurable via `probability` (0-100%)
  - Distribution en temps réel

#### 2. Taux d'Apparition
- **Nouveau champ** : Taux d'apparition en pourcentage (📈)
- Affiché dans le panneau de configuration Discord
- Affiché dans l'application Android
- Contrôle précis de la fréquence des lettres

#### 3. Interface Android Améliorée
- Sélection visuelle du mode de jeu (chips)
- Champs conditionnels selon le mode :
  - Mode Probabilité → Taux en %
  - Mode Quotidien → Nombre de lettres/jour
- Texte d'aide dynamique

### 💬 Système de Mentions

- **Autocomplétion** : Le composant `MemberSelector` permet déjà la recherche et filtrage
- Recherche en temps réel (comme Discord)
- Filtrage par nom ou ID
- Interface intuitive avec dropdown

---

## 🐛 Corrections de Bugs

### Mot-Caché Discord

1. **Emojis non affichés** ✅
   - **Problème** : Le fichier `mot-cache-handler.js` n'était pas sur le serveur
   - **Solution** : Fichier transféré et bot redémarré
   - **Status** : Résolu

2. **Bouton Config - Échec d'interaction** ✅
   - **Problème** : Timeout de 3 secondes Discord
   - **Solution** : Ajout de `deferUpdate()` avant traitement
   - **Status** : Résolu

3. **Toggle Activation** ✅
   - **Problème** : Le panneau se fermait au lieu de se mettre à jour
   - **Solution** : Reconstruction automatique du panneau
   - **Status** : Résolu

---

## 📱 API Backend

### Nouveaux Endpoints

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/mot-cache` | GET | État général du jeu |
| `/api/mot-cache/my-progress` | GET | Progression utilisateur |
| `/api/mot-cache/guess` | POST | Deviner le mot |
| `/api/mot-cache/config` | GET | Config admin (avec mot) |
| `/api/mot-cache/config` | POST | Mettre à jour config |

**URL de base** : `http://88.174.155.230:33003`

### Sécurité
- Authentification Bearer Token requise
- Le mot cible n'est jamais exposé dans les endpoints publics
- Vérification des permissions admin pour les endpoints sensibles

---

## 🎨 Améliorations UI/UX

### Discord Bot

**Panneau de Configuration** (4 rangées) :
```
Row 1: [Activer/Désactiver] [Changer mot] [Mode de jeu]
Row 2: [Emoji] [Taux %] [Longueur min]
Row 3: [Salons jeu] [Salon lettres] [Salon gagnant]
Row 4: [Reset jeu]
```

**Embed Utilisateur** :
- Mot avec lettres révélées : `C A _ _ N`
- Progression en % : `3/5 lettres (60%)`
- Statut du jeu ("✅ Le jeu est actif !")
- Bouton "Entrer le mot" toujours visible

### Application Android

**Config Mot-Caché** :
- Header violet avec icône 🔍
- Switch d'activation
- Champs de configuration groupés par catégorie
- Sélecteurs de channels intuitifs
- Validation en temps réel
- Indicateurs visuels d'état

---

## 📊 Structure de Données

### Configuration `motCache`

```json
{
  "enabled": boolean,
  "targetWord": string,
  "mode": "daily" | "probability",
  "probability": number,        // 0-100 (%)
  "lettersPerDay": number,      // 1-20
  "emoji": string,
  "minMessageLength": number,   // 1-500
  "allowedChannels": string[],
  "letterNotificationChannel": string,
  "winnerNotificationChannel": string,
  "rewardAmount": number,
  "collections": {
    userId: string[]            // Lettres collectées
  },
  "winners": [{
    userId: string,
    username: string,
    word: string,
    date: number,
    reward: number
  }]
}
```

---

## 🔧 Fichiers Modifiés

### Backend (Bot Discord)
- `src/modules/mot-cache-handler.js` ⚠️ **Nouveau - Critique**
- `src/modules/mot-cache-buttons.js` ✏️ Modifié
- `src/commands/mot-cache.js` ✏️ Modifié
- `bot-api-server.js` ✏️ Modifié

### Frontend (Android)
- `app/src/main/java/.../ConfigDashboardScreen.kt` ✏️ Modifié

### Documentation
- `docs/API_MOT_CACHE_ANDROID.md` 📝 Nouveau
- `RESUME_MOT_CACHE_COMPLET.md` 📝 Nouveau

---

## 🚀 Déploiement

### Serveurs
- **Bot Discord** : ✅ Déployé (port 5000)
- **API Server** : ✅ Déployé (port 33003)
- **Dashboard** : ✅ Opérationnel (port 3000)

### Build Android

Pour compiler l'APK :

```bash
cd android-app
chmod +x BUILD_APK.sh
./BUILD_APK.sh
```

Fichier généré : `bagbot-manager-v5.9.15.apk`

---

## 🧪 Tests à Effectuer

### Discord

- [ ] `/mot-cache` → Vérifier affichage avec lettres révélées
- [ ] Cliquer sur "⚙️ Config" → Vérifier que le panneau s'ouvre
- [ ] Changer le mode de jeu → Vérifier le modal
- [ ] Modifier le taux → Vérifier la sauvegarde
- [ ] Envoyer des messages → Vérifier que les emojis apparaissent
- [ ] Tester le bouton toggle → Vérifier reconstruction du panneau

### Android

- [ ] Ouvrir Config → Mot-Caché
- [ ] Vérifier les nouveaux champs (Mode, Taux, Lettres/jour)
- [ ] Changer le mode → Vérifier affichage conditionnel
- [ ] Sauvegarder → Vérifier sur Discord
- [ ] Tester MemberSelector → Vérifier autocomplétion

### API

- [ ] `GET /api/mot-cache` → Vérifier données publiques
- [ ] `GET /api/mot-cache/my-progress` → Vérifier progression
- [ ] `POST /api/mot-cache/guess` → Tester réponse correcte/incorrecte
- [ ] Vérifier que le mot n'est jamais exposé

---

## 📝 Notes Importantes

### ⚠️ Points d'Attention

1. **Mode Quotidien** : Nécessite un CRON job pour la distribution automatique (à implémenter)
2. **Tokens API** : Expirent après 24h
3. **Mot Cible** : Jamais envoyé dans les réponses API publiques
4. **Handler** : Le fichier `mot-cache-handler.js` est critique pour le fonctionnement

### 💡 Suggestions d'Amélioration Future

- Planification horaire pour le mode quotidien
- Statistiques de jeu détaillées
- Classement des joueurs
- Notifications push Android
- Mode multijoueurs entre serveurs

---

## 👥 Contributeurs

- Développement Backend : Bot Discord + API
- Développement Frontend : Application Android
- Documentation : Guide API + CHANGELOG

---

## 📞 Support

Pour toute question ou bug :
- Vérifier les logs : `pm2 logs bagbot`
- Tester l'API : `curl http://88.174.155.230:33003/health`
- Consulter la documentation : `docs/API_MOT_CACHE_ANDROID.md`

---

**🎉 Version 5.9.15 prête pour déploiement !**
