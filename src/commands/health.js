const { SlashCommandBuilder, EmbedBuilder, PermissionFlagsBits } = require('discord.js');

module.exports = {
  name: 'health',
  description: '🏥 Vérifier la santé des données du bot (Admin)',
  dmPermission: false,
  
  data: new SlashCommandBuilder()
    .setName('health')
    .setDescription('🏥 Vérifier la santé des données du bot (Admin)')
    .setDMPermission(false)
    .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

  async execute(interaction) {
    // Vérifier les permissions
    if (!interaction.memberPermissions.has('Administrator')) {
      return interaction.reply({
        content: '❌ Cette commande est réservée aux administrateurs.',
        ephemeral: true
      });
    }

    await interaction.deferReply({ ephemeral: true });

    try {
      // Obtenir le rapport de santé
      const monitor = global.dataHealthMonitor;
      
      if (!monitor) {
        return interaction.editReply({
          content: '❌ Le système de monitoring n\'est pas disponible.'
        });
      }

      const report = await monitor.getHealthReport();

      if (!report) {
        return interaction.editReply({
          content: '❌ Impossible de générer le rapport de santé.'
        });
      }

      // Créer l'embed avec les informations
      const embed = new EmbedBuilder()
        .setTitle('🏥 Rapport de Santé des Données')
        .setColor('#00ff00')
        .setTimestamp(report.timestamp);

      // Statistiques générales
      let description = `**📊 Statistiques Générales**\n`;
      description += `• Serveurs: **${report.guilds.length}**\n`;
      description += `• Utilisateurs totaux: **${report.totalUsers}**\n`;
      description += `• Dernière vérification: **${report.timestamp.toLocaleString('fr-FR')}**\n\n`;

      // Détails par serveur
      for (const guild of report.guilds) {
        const guildObj = interaction.client.guilds.cache.get(guild.id);
        const guildName = guildObj ? guildObj.name : guild.id;
        
        description += `**${guildName}**\n`;
        description += `• Utilisateurs: **${guild.users}**\n`;
        
        // État du jeu mot-caché
        if (guild.motCache.enabled) {
          description += `• Mot-caché: **Actif** `;
          description += `(${guild.motCache.collectors} joueurs, ${guild.motCache.winners} gagnants)\n`;
        } else if (guild.motCache.hasWord && !guild.motCache.enabled) {
          description += `• Mot-caché: ⚠️  **Arrêté** `;
          description += `(${guild.motCache.collectors} joueurs sans gagnant)\n`;
        } else {
          description += `• Mot-caché: **Désactivé**\n`;
        }
        
        description += `\n`;
      }

      // Informations sur les backups
      if (report.backups) {
        description += `**💾 Système de Sauvegarde**\n`;
        description += `• Backups disponibles: **${report.backups.count}**\n`;
        
        if (report.backups.newest) {
          description += `• Dernier backup: **${report.backups.newest.date}**\n`;
          description += `• Utilisateurs sauvegardés: **${report.backups.newest.users}**\n`;
        }
        
        if (report.backups.oldest) {
          description += `• Plus ancien: **${report.backups.oldest.date}** (${report.backups.oldest.age})\n`;
        }
        
        description += `• Espace utilisé: **${report.backups.totalSizeMB} MB**\n`;
        description += `• Rétention: **${report.backups.retentionHours}h** (${(report.backups.retentionHours / 24).toFixed(1)} jours)\n`;
      } else {
        description += `**💾 Système de Sauvegarde**\n`;
        description += `⚠️  Informations non disponibles\n`;
      }

      embed.setDescription(description);

      // Ajouter des recommandations si nécessaire
      const warnings = [];
      
      if (report.totalUsers < 10) {
        warnings.push('⚠️ Très peu d\'utilisateurs détectés ! Vérifiez l\'intégrité des données.');
      }

      if (report.backups && report.backups.count < 3) {
        warnings.push('⚠️ Peu de backups disponibles. Le système devrait créer plus de sauvegardes.');
      }

      // Vérifier les jeux mot-caché arrêtés
      for (const guild of report.guilds) {
        if (guild.motCache.hasWord && !guild.motCache.enabled && guild.motCache.collectors > 0) {
          warnings.push(`⚠️ Jeu mot-caché arrêté sans gagnant sur un serveur (${guild.motCache.collectors} joueurs affectés)`);
        }
      }

      if (warnings.length > 0) {
        embed.addFields({
          name: '⚠️ Avertissements',
          value: warnings.join('\n')
        });
        embed.setColor('#ff9900');
      }

      // Ajouter un footer avec des commandes utiles
      embed.setFooter({
        text: 'Commandes: /backup (sauvegarder), /restore (restaurer), /cleanup (nettoyer)'
      });

      return interaction.editReply({ embeds: [embed] });

    } catch (error) {
      console.error('[Health] Erreur:', error);
      return interaction.editReply({
        content: `❌ Erreur lors de la génération du rapport: ${error.message}`
      });
    }
  }
};
