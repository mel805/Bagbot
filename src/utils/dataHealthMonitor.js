/**
 * SYSTÈME DE SURVEILLANCE DE LA SANTÉ DES DONNÉES
 * 
 * Ce module surveille en continu la santé des données du bot et alerte
 * les administrateurs en cas de problème détecté.
 * 
 * Fonctionnalités :
 * - Détection de perte de données (chute du nombre d'utilisateurs)
 * - Alerte Discord automatique en cas de problème
 * - Vérification de l'intégrité des backups
 * - Monitoring du jeu mot-caché
 */

const { readConfig } = require('../storage/jsonStore');
const { EmbedBuilder } = require('discord.js');

class DataHealthMonitor {
  constructor(client) {
    this.client = client;
    this.lastUserCount = 0;
    this.lastCheck = null;
    this.alertChannelId = null; // À configurer
    this.checkInterval = null;
  }

  /**
   * Démarrer le monitoring
   */
  start(alertChannelId = null) {
    console.log('[DataHealth] 🔍 Démarrage du monitoring de santé des données');
    this.alertChannelId = alertChannelId;

    // Faire une première vérification immédiate
    this.performHealthCheck().catch(err => {
      console.error('[DataHealth] Erreur check initial:', err.message);
    });

    // Vérifier toutes les 10 minutes
    this.checkInterval = setInterval(() => {
      this.performHealthCheck().catch(err => {
        console.error('[DataHealth] Erreur check automatique:', err.message);
      });
    }, 10 * 60 * 1000); // 10 minutes

    console.log('[DataHealth] ✅ Monitoring démarré (vérification toutes les 10 minutes)');
  }

  /**
   * Arrêter le monitoring
   */
  stop() {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
      console.log('[DataHealth] ⏹️  Monitoring arrêté');
    }
  }

  /**
   * Effectuer une vérification de santé
   */
  async performHealthCheck() {
    try {
      const config = await readConfig();
      const now = new Date();

      // Compter les utilisateurs
      let totalUsers = 0;
      let totalGuilds = 0;
      const guildStats = {};

      if (config.guilds) {
        totalGuilds = Object.keys(config.guilds).length;

        for (const guildId in config.guilds) {
          const guild = config.guilds[guildId];
          let userCount = 0;

          if (guild.economy?.balances) {
            userCount = Object.keys(guild.economy.balances).length;
            totalUsers += userCount;
          }

          guildStats[guildId] = {
            users: userCount,
            motCache: guild.motCache || {}
          };
        }
      }

      // Détecter une perte de données (chute > 50%)
      if (this.lastUserCount > 0) {
        const lossPercent = ((this.lastUserCount - totalUsers) / this.lastUserCount) * 100;

        if (lossPercent > 50) {
          console.error(`[DataHealth] 🚨 ALERTE: Perte de ${lossPercent.toFixed(1)}% des utilisateurs !`);
          console.error(`[DataHealth] Avant: ${this.lastUserCount}, Maintenant: ${totalUsers}`);

          await this.sendAlert({
            title: '🚨 ALERTE: Perte de Données Détectée',
            color: '#ff0000',
            description: `**Une perte massive de données a été détectée !**\n\n` +
              `📊 Utilisateurs avant: **${this.lastUserCount}**\n` +
              `📊 Utilisateurs maintenant: **${totalUsers}**\n` +
              `📉 Perte: **${Math.abs(lossPercent).toFixed(1)}%** (${this.lastUserCount - totalUsers} utilisateurs)\n\n` +
              `⚠️ **Action recommandée:** Vérifier immédiatement et restaurer depuis un backup si nécessaire !`,
            timestamp: now
          });
        } else if (lossPercent > 10) {
          console.warn(`[DataHealth] ⚠️  Perte modérée: ${lossPercent.toFixed(1)}% des utilisateurs`);
        }
      }

      // Vérifier l'état du jeu mot-caché
      for (const guildId in guildStats) {
        const motCache = guildStats[guildId].motCache;

        // Vérifier si le jeu a été désactivé brusquement
        if (motCache.enabled === false && motCache.targetWord && !motCache.winners?.length) {
          console.warn(`[DataHealth] ⚠️  Jeu mot-caché désactivé sans gagnant sur serveur ${guildId}`);
          
          // Vérifier s'il y avait des lettres collectées
          let totalCollectors = 0;
          if (motCache.collections) {
            totalCollectors = Object.keys(motCache.collections).length;
          }

          if (totalCollectors > 0) {
            await this.sendAlert({
              title: '⚠️ Jeu Mot-Caché Interrompu',
              color: '#ff9900',
              description: `**Le jeu mot-caché s'est arrêté sans gagnant !**\n\n` +
                `🎯 Mot: **${motCache.targetWord || '(non défini)'}**\n` +
                `👥 Joueurs ayant collecté des lettres: **${totalCollectors}**\n` +
                `📊 État: **Désactivé**\n\n` +
                `💡 Le jeu peut être réactivé ou réinitialisé avec \`/mot-cache\``,
              timestamp: now
            });
          }
        }
      }

      // Mettre à jour les stats
      this.lastUserCount = totalUsers;
      this.lastCheck = now;

      // Log périodique (toutes les heures seulement)
      if (!this.lastLogTime || (now - this.lastLogTime) >= 60 * 60 * 1000) {
        console.log(`[DataHealth] ✅ Check OK - ${totalUsers} utilisateurs, ${totalGuilds} serveurs`);
        this.lastLogTime = now;
      }

      return {
        success: true,
        totalUsers,
        totalGuilds,
        timestamp: now
      };

    } catch (error) {
      console.error('[DataHealth] Erreur check santé:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Envoyer une alerte Discord
   */
  async sendAlert(embedData) {
    if (!this.alertChannelId || !this.client) {
      console.warn('[DataHealth] Pas de salon d\'alerte configuré');
      return;
    }

    try {
      const channel = await this.client.channels.fetch(this.alertChannelId);
      if (!channel) {
        console.warn('[DataHealth] Salon d\'alerte introuvable');
        return;
      }

      const embed = new EmbedBuilder()
        .setTitle(embedData.title)
        .setColor(embedData.color)
        .setDescription(embedData.description)
        .setTimestamp(embedData.timestamp)
        .setFooter({ text: 'Système de Monitoring BagBot' });

      await channel.send({ embeds: [embed] });
      console.log('[DataHealth] ✅ Alerte envoyée');

    } catch (error) {
      console.error('[DataHealth] Erreur envoi alerte:', error.message);
    }
  }

  /**
   * Obtenir un rapport de santé complet
   */
  async getHealthReport() {
    try {
      const config = await readConfig();
      const report = {
        timestamp: new Date(),
        guilds: [],
        totalUsers: 0,
        backups: null
      };

      // Analyser chaque serveur
      if (config.guilds) {
        for (const guildId in config.guilds) {
          const guild = config.guilds[guildId];
          const userCount = guild.economy?.balances ? Object.keys(guild.economy.balances).length : 0;
          
          report.totalUsers += userCount;
          report.guilds.push({
            id: guildId,
            users: userCount,
            motCache: {
              enabled: guild.motCache?.enabled || false,
              hasWord: Boolean(guild.motCache?.targetWord),
              collectors: guild.motCache?.collections ? Object.keys(guild.motCache.collections).length : 0,
              winners: guild.motCache?.winners?.length || 0
            }
          });
        }
      }

      // Vérifier les backups
      if (global.hourlyBackupSystem) {
        try {
          const stats = await global.hourlyBackupSystem.getStats();
          report.backups = stats;
        } catch (err) {
          console.error('[DataHealth] Erreur stats backup:', err.message);
        }
      }

      return report;

    } catch (error) {
      console.error('[DataHealth] Erreur rapport santé:', error.message);
      return null;
    }
  }
}

module.exports = DataHealthMonitor;
