# 🤖 BAG Bot Dashboard - Application Mobile Android

Application mobile complète pour gérer votre serveur Discord via le BAG Bot Dashboard.

## 📱 Fonctionnalités

✅ **Dashboard Principal**
- Vue d'ensemble des statistiques du serveur
- Nombre de membres total et actifs
- Statistiques économie et tickets
- Actions rapides

✅ **Économie** 💰
- Gestion de la monnaie virtuelle (BAG$)
- Configuration des cooldowns
- Top utilisateurs
- Gestion de la boutique

✅ **Musique** 🎵
- Gestion des playlists
- Ajout/suppression de playlists
- Vue des pistes

✅ **Jeux** 🎲
- Action ou Vérité
- Comptage
- Configuration des salons

✅ **Boutique** 🛒
- Gestion des articles
- Ajout/modification/suppression d'items
- Prix en BAG$

✅ **Inactivité** 💤
- Suivi des membres inactifs
- Nettoyage automatique
- Statistiques détaillées

✅ **Tickets** 🎫
- Gestion des catégories de tickets
- Configuration des emojis et descriptions

✅ **Configuration** ⚙️
- Changement de serveur
- Paramètres de l'app
- Déconnexion

## 🚀 Installation

### Méthode 1 : APK Direct (Recommandé)

1. Téléchargez le fichier APK généré
2. Activez "Sources inconnues" sur votre Android
3. Installez l'APK

### Méthode 2 : Build depuis le code source

```bash
# Cloner le projet
cd BagBotApp

# Installer les dépendances
npm install

# Générer l'APK avec Expo
npx expo export --platform android

# Ou utiliser EAS Build
npx eas build --platform android --profile production
```

## 🔧 Configuration

1. **Première connexion:**
   - Ouvrez l'application
   - Entrez l'URL de votre serveur : `http://88.174.155.230:3002`
   - Cliquez sur "Connexion"

2. **Changement de serveur:**
   - Allez dans "Config" ⚙️
   - Modifiez l'URL du serveur
   - Cliquez sur "Changer de serveur"

## 📡 API Endpoints

L'application se connecte aux endpoints suivants du dashboard :

- `/api/config` - Configuration générale
- `/api/economy` - Données économie
- `/api/shop` - Boutique
- `/api/music` - Playlists musicales
- `/api/truthdare` - Action ou Vérité
- `/api/counting` - Comptage
- `/api/tickets` - Gestion tickets
- `/api/inactivity` - Inactivité membres
- `/api/discord/*` - Données Discord

## 🎨 Design

- **Thème:** Dark Mode (noir/rouge)
- **Couleurs principales:**
  - Fond: #0d0d0d
  - Cards: #1a1a1a
  - Accent: #FF0000
  - Texte: #ffffff

## 📦 Technologies

- **Framework:** React Native + Expo
- **Navigation:** React Navigation (Stack + Bottom Tabs)
- **UI:** React Native Paper
- **Icons:** Expo Vector Icons
- **HTTP:** Axios
- **Storage:** AsyncStorage

## 🔐 Sécurité

- Connexion sécurisée avec authentification
- Stockage local des préférences
- Validation des entrées utilisateur
- Gestion des erreurs réseau

## 📱 Compatibilité

- **Android:** 5.0 (Lollipop) et supérieur
- **iOS:** Compatible (non testé)
- **Taille APK:** ~50-60 MB

## 🐛 Debug

Pour tester l'application en mode développement :

```bash
# Démarrer le serveur Expo
npm start

# Scanner le QR code avec Expo Go
# Ou lancer directement sur Android
npm run android
```

## 📄 Licence

Propriété de BAG Bot - Tous droits réservés

## 👨‍💻 Support

Pour toute question ou problème :
- Vérifiez que le serveur est accessible
- Vérifiez l'URL du serveur dans les paramètres
- Redémarrez l'application

## 🎯 Version

**v1.0.0** - Version initiale complète

---

Développé avec ❤️ pour BAG Bot Dashboard
