# 🎒 Bag Bot - Bot Discord Multi-fonctions

Bot Discord complet avec système d'économie, niveaux, modération et commandes interactives.

## ✨ Fonctionnalités principales

### 💰 Système d'économie
- Solde et transactions
- Commandes de travail et de crime
- Vol entre utilisateurs
- Boutique intégrée

### 📊 Système de niveaux
- XP et progression automatique
- Classement (leaderboard)
- Rôles de niveaux configurables

### 🛡️ Modération
- Ban/Unban, Kick, Mute/Unmute
- Purge de messages
- Système d'avertissements
- Logs détaillés

### 🔄 Sauvegardes
- Sauvegarde manuelle (`/backup`)
- Sauvegardes automatiques
- Restauration avec pagination (`/restore`)
- Support GitHub pour backup distant

### 🎮 Commandes interactives
- Plus de 60 commandes d'action (câlin, bisou, gifle, etc.)
- Système de mariage et relations
- Mini-jeux (action ou vérité, etc.)
- Commandes personnalisées par serveur

### ⚙️ Configuration
- Configuration par serveur
- Système de logs personnalisable
- Rôles staff configurables
- Préfixes personnalisés

## 🚀 Installation

### Prérequis
- Node.js 16.x ou supérieur
- npm ou yarn
- Un bot Discord (token)

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/votre-username/Bag-bot.git
cd Bag-bot

# Installer les dépendances
npm install

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos tokens

# Déployer les commandes Discord
node deploy-commands.js

# Lancer le bot
node src/bot.js
```

### Avec PM2 (production)

```bash
# Installer PM2
npm install -g pm2

# Lancer le bot
pm2 start src/bot.js --name bot

# Sauvegarder la configuration PM2
pm2 save
pm2 startup
```

## 📝 Configuration

### Variables d'environnement (.env)

```env
DISCORD_TOKEN=votre_token_discord
CLIENT_ID=votre_client_id
DATA_DIR=/chemin/vers/data
USE_PG=false
```

### Structure des données

Le bot stocke ses données dans des fichiers JSON par défaut :
- `data/config.json` - Configuration des serveurs
- `data/backups/` - Sauvegardes automatiques et manuelles

## 🎯 Commandes principales

### Économie
- `/solde` - Voir son solde
- `/top` - Classement économie/XP
- `/daily` - Bonus quotidien
- `/travailler` - Gagner de l'argent
- `/voler @user` - Tenter de voler

### Modération (Admin/Staff)
- `/ban @user [raison]` - Bannir un membre
- `/kick @user [raison]` - Expulser un membre
- `/mute @user minutes [raison]` - Rendre muet
- `/purge nombre` - Supprimer des messages
- `/warn @user [raison]` - Avertir un membre

### Configuration (Admin)
- `/config` - Configuration du serveur
- `/setlogs` - Configurer les logs
- `/backup` - Créer une sauvegarde
- `/restore` - Restaurer une sauvegarde

### Interactions
- `/câlin @user` - Faire un câlin
- `/bisou @user` - Faire un bisou
- `/gifle @user` - Gifler quelqu'un
- `/marry @user` - Demander en mariage
- Et 50+ autres commandes...

## 🏗️ Architecture

```
Bag-bot/
├── src/
│   ├── bot.js              # Point d'entrée principal
│   ├── commands/           # Commandes séparées (modulaire)
│   │   ├── backup.js
│   │   ├── restore.js
│   │   ├── solde.js
│   │   └── ...
│   ├── handlers/           # Gestionnaires
│   │   └── commandHandler.js
│   ├── helpers/            # Fonctions utilitaires
│   │   ├── showRestoreMenu.js
│   │   ├── listLocalBackups.js
│   │   └── ...
│   └── storage/            # Gestion des données
│       └── jsonStore.js
├── deploy-commands.js      # Déploiement des commandes Discord
├── package.json
└── README.md
```

## 🔧 Développement

### Ajouter une nouvelle commande

1. Créer un fichier dans `src/commands/`:

```javascript
// src/commands/macommande.js
module.exports = {
  name: 'macommande',
  description: 'Description de ma commande',
  
  async execute(interaction) {
    await interaction.reply('Hello World!');
  },
  
  // Optionnel: gérer les interactions (boutons, menus)
  async handleInteraction(interaction) {
    // ...
    return true; // ou false si non géré
  }
};
```

2. Redéployer les commandes:
```bash
node deploy-commands.js
```

3. Redémarrer le bot:
```bash
pm2 restart bot
```

## 📦 Sauvegardes

### Types de sauvegardes

- **👤 Manuel** : Créées avec `/backup`
- **🤖 Auto** : Créées automatiquement toutes les heures
- **🛡️ Sécurité** : Créées avant chaque restauration

### Restauration

```bash
/restore
```

- Navigation par pages (25 sauvegardes/page)
- Filtrage par type
- Sauvegarde de sécurité automatique

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

Développé avec ❤️ pour la communauté Discord

## 🆘 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation

## 📊 Changelog

Voir `CORRECTION_RESTORE.md` pour les dernières corrections apportées au système de restauration.
