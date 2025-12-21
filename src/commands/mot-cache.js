const { SlashCommandBuilder, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle, ModalBuilder, TextInputBuilder, TextInputStyle, StringSelectMenuBuilder } = require('discord.js');
const { readConfig, writeConfig } = require('../storage/jsonStore');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('mot-cache')
    .setDescription('🔍 Jeu du mot caché - Collecte les lettres!')
    .addSubcommand(sub => sub
      .setName('jouer')
      .setDescription('📋 Voir tes lettres collectées'))
    .addSubcommand(sub => sub
      .setName('deviner')
      .setDescription('🎯 Proposer un mot')
      .addStringOption(opt => opt
        .setName('mot')
        .setDescription('Le mot que tu penses avoir trouvé')
        .setRequired(true)))
    .addSubcommand(sub => sub
      .setName('config')
      .setDescription('⚙️ Configurer le jeu (admin seulement)')),

  async execute(interaction) {
    const subcommand = interaction.options.getSubcommand();
    const config = await readConfig();
    const guildConfig = config.guilds[interaction.guildId] || {};
    const motCache = guildConfig.motCache || {
      enabled: false,
      targetWord: '',
      mode: 'programmed', // 'programmed' ou 'probability'
      lettersPerDay: 1,
      probability: 5, // %
      emoji: '🔍',
      minMessageLength: 15,
      allowedChannels: [], // vide = tous
      notificationChannel: null,
      collections: {}, // userId: ['A', 'L', 'I']
      winners: [] // [{userId, word, date, reward}]
    };

    if (subcommand === 'jouer') {
      // Afficher les lettres collectées
      const userId = interaction.user.id;
      const userLetters = motCache.collections[userId] || [];
      
      if (!motCache.enabled || !motCache.targetWord) {
        return interaction.reply({
          content: '❌ Le jeu du mot caché n\'est pas activé actuellement.',
          ephemeral: true
        });
      }

      const embed = new EmbedBuilder()
        .setTitle('🔍 Mot Caché - Tes Lettres')
        .setDescription(`**Lettres collectées:** ${userLetters.length > 0 ? userLetters.join(' ') : 'Aucune'}`)
        .addFields(
          { name: '📊 Progression', value: `${userLetters.length}/${motCache.targetWord.length} lettres`, inline: true },
          { name: '🎯 Objectif', value: `Trouver le mot de ${motCache.targetWord.length} lettres`, inline: true }
        )
        .setColor('#9b59b6')
        .setFooter({ text: 'Utilise /mot-cache deviner <mot> pour proposer !' });

      return interaction.reply({ embeds: [embed], ephemeral: true });
    }

    if (subcommand === 'deviner') {
      const guessedWord = interaction.options.getString('mot').toUpperCase().trim();
      const userId = interaction.user.id;
      const userLetters = motCache.collections[userId] || [];

      if (!motCache.enabled || !motCache.targetWord) {
        return interaction.reply({
          content: '❌ Le jeu du mot caché n\'est pas activé.',
          ephemeral: true
        });
      }

      if (guessedWord === motCache.targetWord.toUpperCase()) {
        // GAGNÉ !
        const reward = 5000; // Récompense fixe
        
        // Ajouter l'argent
        if (!guildConfig.economy) guildConfig.economy = { balances: {} };
        if (!guildConfig.economy.balances) guildConfig.economy.balances = {};
        if (!guildConfig.economy.balances[userId]) {
          guildConfig.economy.balances[userId] = { amount: 0, money: 0 };
        }
        guildConfig.economy.balances[userId].amount += reward;
        guildConfig.economy.balances[userId].money += reward;

        // Enregistrer le gagnant
        if (!motCache.winners) motCache.winners = [];
        motCache.winners.push({
          userId,
          username: interaction.user.username,
          word: motCache.targetWord,
          date: Date.now(),
          reward
        });

        // Reset les collections
        motCache.collections = {};
        motCache.targetWord = '';
        motCache.enabled = false;

        guildConfig.motCache = motCache;
        await writeConfig(config);

        const embed = new EmbedBuilder()
          .setTitle('🎉 FÉLICITATIONS !')
          .setDescription(`**Tu as trouvé le mot caché !**\n\n🎯 Mot: **${guessedWord}**\n💰 Récompense: **${reward} BAG$**`)
          .setColor('#2ecc71')
          .setFooter({ text: 'Bravo !' });

        // Notifier dans le salon de notifications
        if (motCache.notificationChannel) {
          const notifChannel = interaction.guild.channels.cache.get(motCache.notificationChannel);
          if (notifChannel) {
            notifChannel.send({
              content: `🎉 <@${userId}> a trouvé le mot caché : **${guessedWord}** !`,
              embeds: [embed]
            });
          }
        }

        return interaction.reply({ embeds: [embed] });
      } else {
        return interaction.reply({
          content: `❌ Ce n'est pas le bon mot ! Continue à collecter des lettres.\n\n📋 Tes lettres: ${userLetters.join(' ') || 'Aucune'}`,
          ephemeral: true
        });
      }
    }

    if (subcommand === 'config') {
      // Vérifier permissions admin
      if (!interaction.memberPermissions.has('Administrator')) {
        return interaction.reply({
          content: '❌ Seuls les administrateurs peuvent configurer le jeu.',
          ephemeral: true
        });
      }

      const embed = new EmbedBuilder()
        .setTitle('⚙️ Configuration Mot-Caché')
        .setDescription('────────────────────────────')
        .addFields(
          { name: '📊 État', value: motCache.enabled ? '✅ Activé' : '⏸️ Désactivé', inline: true },
          { name: '🎯 Mot cible', value: motCache.targetWord || 'Non défini', inline: true },
          { name: '🔍 Emoji', value: motCache.emoji, inline: true },
          { name: '🎲 Mode', value: motCache.mode === 'programmed' ? '📅 Programmé' : '🎲 Probabilité', inline: true },
          { name: '📅 Lettres/jour', value: motCache.mode === 'programmed' ? `${motCache.lettersPerDay}` : 'N/A', inline: true },
          { name: '📊 Probabilité', value: motCache.mode === 'probability' ? `${motCache.probability}%` : 'N/A', inline: true },
          { name: '📏 Longueur min', value: `${motCache.minMessageLength} caractères`, inline: true },
          { name: '📋 Salons jeu', value: motCache.allowedChannels && motCache.allowedChannels.length > 0 ? `${motCache.allowedChannels.length} salons` : 'Tous', inline: true },
          { name: '💬 Salon lettres', value: motCache.letterNotificationChannel ? `<#${motCache.letterNotificationChannel}>` : 'Non configuré', inline: true },
          { name: '📢 Salon gagnant', value: motCache.notificationChannel ? `<#${motCache.notificationChannel}>` : 'Non configuré', inline: true }
        )
        .setColor('#9b59b6');

      const row1 = new ActionRowBuilder().addComponents(
        new ButtonBuilder()
          .setCustomId('motcache_toggle')
          .setLabel(motCache.enabled ? '⏸️ Désactiver' : '▶️ Activer')
          .setStyle(motCache.enabled ? ButtonStyle.Danger : ButtonStyle.Success),
        new ButtonBuilder()
          .setCustomId('motcache_setword')
          .setLabel('🎯 Changer le mot')
          .setStyle(ButtonStyle.Primary),
        new ButtonBuilder()
          .setCustomId('motcache_mode')
          .setLabel('🎲 Changer mode')
          .setStyle(ButtonStyle.Secondary)
      );

      const row2 = new ActionRowBuilder().addComponents(
        new ButtonBuilder()
          .setCustomId('motcache_probability')
          .setLabel('📊 Probabilité')
          .setStyle(ButtonStyle.Secondary)
          .setDisabled(motCache.mode !== 'probability'),
        new ButtonBuilder()
          .setCustomId('motcache_lettersperday')
          .setLabel('📅 Lettres/jour')
          .setStyle(ButtonStyle.Secondary)
          .setDisabled(motCache.mode !== 'programmed'),
        new ButtonBuilder()
          .setCustomId('motcache_emoji')
          .setLabel('🔍 Emoji')
          .setStyle(ButtonStyle.Secondary)
      );

      const row3 = new ActionRowBuilder().addComponents(
        new ButtonBuilder()
          .setCustomId('motcache_gamechannels')
          .setLabel('📋 Salons jeu')
          .setStyle(ButtonStyle.Secondary),
        new ButtonBuilder()
          .setCustomId('motcache_letternotifchannel')
          .setLabel('💬 Salon lettres')
          .setStyle(ButtonStyle.Secondary),
        new ButtonBuilder()
          .setCustomId('motcache_winnernotifchannel')
          .setLabel('📢 Salon gagnant')
          .setStyle(ButtonStyle.Secondary),
        new ButtonBuilder()
          .setCustomId('motcache_reset')
          .setLabel('🔄 Reset jeu')
          .setStyle(ButtonStyle.Danger)
      );

      return interaction.reply({
        embeds: [embed],
        components: [row1, row2, row3],
        ephemeral: true
      });
    }
  }
};
