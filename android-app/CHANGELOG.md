# Changelog - BAG Bot Manager Android

## [2.2.0] - 2025-12-19

### ✨ Nouvelles Fonctionnalités

#### Informations Enrichies du Bot
- Ajout des statistiques détaillées du bot dans l'écran d'accueil
- Affichage du temps de fonctionnement (uptime) du bot
- Affichage du nombre de redémarrages
- Affichage de l'utilisation mémoire et CPU (via PM2)

#### Informations du Serveur Discord
- Nouvelle section affichant le nom du serveur Discord
- Compteurs détaillés : membres totaux, salons, rôles
- Statistiques économie : nombre d'utilisateurs actifs et monnaie totale
- Statistiques de niveaux : niveau maximum atteint par les membres
- Icône du serveur Discord (à venir)

#### Nouveau Dashboard Info
- Nouvelle carte "Dashboard" dans l'écran d'accueil
- Affichage de la version du dashboard (v2.8)
- Temps de fonctionnement du dashboard
- Port d'écoute du serveur
- Statistiques de stockage :
  - Nombre de sauvegardes disponibles
  - Nombre de fichiers uploadés
  - Taille du fichier de configuration
- Liste visuelle des fonctionnalités actives avec emojis :
  - 💰 Économie
  - 📊 Niveaux
  - 🎲 Action/Vérité
  - 🎫 Tickets
  - 💬 Confessions
  - 🚪 Auto-kick
  - 🔢 Comptage
  - 🌍 Géolocalisation
  - 🎵 Musique

### 🔧 Améliorations Backend

#### API `/api/bot/status` Enrichie
- Ajout des informations du serveur Discord (guild)
- Ajout des statistiques d'économie et de niveaux
- Ajout des métriques système (mémoire, CPU)
- Récupération automatique du nombre de membres/salons/rôles

#### Nouvelle API `/api/dashboard/info`
- Exposition des informations du dashboard
- Liste des fonctionnalités activées/désactivées
- Statistiques de stockage et de configuration
- Informations système (OS, version Node.js, hostname)

### 🎨 Améliorations UI/UX

- Design amélioré de la carte "Statut du Bot"
- Meilleure organisation des informations avec dividers
- Codes couleur cohérents pour les différentes statistiques
- Emojis pour une meilleure lisibilité
- Messages de chargement plus informatifs lors du démarrage

### 🐛 Corrections de Bugs
- Correction du typo dans l'affichage de la version (Bot au lieu de juste Version)
- Amélioration de la gestion des erreurs lors du chargement des données
- Meilleure gestion des données nulles/manquantes

### 📝 Documentation
- Ajout d'un README.md complet
- Documentation des nouvelles APIs
- Guide d'installation et de configuration
- Section résolution de problèmes

### 🔐 Sécurité
- Pas de changements majeurs, même niveau de sécurité OAuth

---

## [2.1.8] - Précédente Version

### Fonctionnalités
- Chat staff intégré
- Corrections critiques de sécurité
- Amélioration de l'affichage des noms réels (rôles, channels, membres)

---

## [2.1.7] - Version Complète

### Fonctionnalités
- Application ultra-complète avec toutes les fonctionnalités
- Éditeurs de configuration par catégories
- Gestion complète du bot depuis l'app mobile

---

## [2.1.0] - Version Complète Recréée

### Fonctionnalités
- Reconstruction complète de l'application
- Architecture améliorée
- UI modernisée avec Material 3

---

## [2.0.x] - Versions Initiales

### Fonctionnalités
- Lancement initial de l'application
- Authentification OAuth Discord
- Gestion basique de la configuration
- Interface par vignettes catégorisées
