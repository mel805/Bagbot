// Handlers pour les boutons de configuration mot-caché
// À intégrer dans bot.js dans la section client.on('interactionCreate')

const { ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder, StringSelectMenuBuilder, EmbedBuilder } = require('discord.js');
const { readConfig, writeConfig } = require('../storage/jsonStore');

async function handleMotCacheButton(interaction) {
  const config = await readConfig();
  const guildConfig = config.guilds[interaction.guildId] || {};
  const motCache = guildConfig.motCache || {
    enabled: false,
    targetWord: '',
    mode: 'programmed',
    lettersPerDay: 1,
    probability: 5,
    emoji: '🔍',
    minMessageLength: 15,
    allowedChannels: [],
    notificationChannel: null,
    collections: {},
    winners: []
  };

  const buttonId = interaction.customId;

  // Toggle enabled/disabled
  if (buttonId === 'motcache_toggle') {
    motCache.enabled = !motCache.enabled;
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.update({
      content: `✅ Jeu mot-caché ${motCache.enabled ? '**activé**' : '**désactivé**'}`,
      embeds: [],
      components: []
    });
  }

  // Changer le mot
  if (buttonId === 'motcache_setword') {
    const modal = new ModalBuilder()
      .setCustomId('motcache_modal_setword')
      .setTitle('🎯 Définir le mot caché');

    const wordInput = new TextInputBuilder()
      .setCustomId('word')
      .setLabel('Mot à trouver')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('Ex: CALIN, BOUTEILLE')
      .setRequired(true)
      .setValue(motCache.targetWord || '');

    modal.addComponents(new ActionRowBuilder().addComponents(wordInput));
    return interaction.showModal(modal);
  }

  // Changer le mode
  if (buttonId === 'motcache_mode') {
    const menu = new StringSelectMenuBuilder()
      .setCustomId('motcache_select_mode')
      .setPlaceholder('Choisir le mode de jeu')
      .addOptions([
        {
          label: '📅 Programmé',
          description: 'X lettres par jour à heure fixe',
          value: 'programmed'
        },
        {
          label: '🎲 Probabilité',
          description: 'Chance aléatoire sur chaque message',
          value: 'probability'
        }
      ]);

    return interaction.update({
      content: '🎲 Sélectionne le mode de jeu :',
      components: [new ActionRowBuilder().addComponents(menu)]
    });
  }

  // Probabilité
  if (buttonId === 'motcache_probability') {
    const modal = new ModalBuilder()
      .setCustomId('motcache_modal_probability')
      .setTitle('📊 Probabilité');

    const probInput = new TextInputBuilder()
      .setCustomId('probability')
      .setLabel('Probabilité (%)')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('Ex: 5 pour 5%')
      .setRequired(true)
      .setValue(motCache.probability?.toString() || '5');

    modal.addComponents(new ActionRowBuilder().addComponents(probInput));
    return interaction.showModal(modal);
  }

  // Lettres par jour
  if (buttonId === 'motcache_lettersperday') {
    const modal = new ModalBuilder()
      .setCustomId('motcache_modal_lettersperday')
      .setTitle('📅 Lettres par jour');

    const lettersInput = new TextInputBuilder()
      .setCustomId('letters')
      .setLabel('Nombre de lettres par jour')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('Ex: 1, 2, 3...')
      .setRequired(true)
      .setValue(motCache.lettersPerDay?.toString() || '1');

    modal.addComponents(new ActionRowBuilder().addComponents(lettersInput));
    return interaction.showModal(modal);
  }

  // Emoji
  if (buttonId === 'motcache_emoji') {
    const modal = new ModalBuilder()
      .setCustomId('motcache_modal_emoji')
      .setTitle('🔍 Emoji de réaction');

    const emojiInput = new TextInputBuilder()
      .setCustomId('emoji')
      .setLabel('Emoji')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('Ex: 🔍, 🎯, ⭐')
      .setRequired(true)
      .setValue(motCache.emoji || '🔍');

    modal.addComponents(new ActionRowBuilder().addComponents(emojiInput));
    return interaction.showModal(modal);
  }

  // Reset jeu
  if (buttonId === 'motcache_reset') {
    motCache.collections = {};
    motCache.targetWord = '';
    motCache.enabled = false;
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.update({
      content: '🔄 **Jeu réinitialisé !**\nToutes les collections ont été effacées.',
      embeds: [],
      components: []
    });
  }
}

// Handler pour les modals
async function handleMotCacheModal(interaction) {
  const config = await readConfig();
  const guildConfig = config.guilds[interaction.guildId] || {};
  const motCache = guildConfig.motCache || {};

  const modalId = interaction.customId;

  if (modalId === 'motcache_modal_setword') {
    const newWord = interaction.fields.getTextInputValue('word').toUpperCase().trim();
    
    if (newWord.length < 1) {
      return interaction.reply({
        content: '❌ Le mot doit contenir au moins 1 caractère.',
        ephemeral: true
      });
    }

    // Reset le jeu quand on change de mot
    motCache.targetWord = newWord;
    motCache.collections = {};
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.reply({
      content: `✅ Mot défini : **${newWord}**\n🔄 Toutes les collections ont été réinitialisées.`,
      ephemeral: true
    });
  }

  if (modalId === 'motcache_modal_probability') {
    const prob = parseInt(interaction.fields.getTextInputValue('probability'));
    
    if (isNaN(prob) || prob < 0 || prob > 100) {
      return interaction.reply({
        content: '❌ La probabilité doit être entre 0 et 100.',
        ephemeral: true
      });
    }

    motCache.probability = prob;
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.reply({
      content: `✅ Probabilité définie : **${prob}%**`,
      ephemeral: true
    });
  }

  if (modalId === 'motcache_modal_lettersperday') {
    const letters = parseInt(interaction.fields.getTextInputValue('letters'));
    
    if (isNaN(letters) || letters < 1 || letters > 20) {
      return interaction.reply({
        content: '❌ Le nombre de lettres doit être entre 1 et 20.',
        ephemeral: true
      });
    }

    motCache.lettersPerDay = letters;
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.reply({
      content: `✅ Lettres par jour : **${letters}**`,
      ephemeral: true
    });
  }

  if (modalId === 'motcache_modal_emoji') {
    const emoji = interaction.fields.getTextInputValue('emoji').trim();
    
    motCache.emoji = emoji;
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.reply({
      content: `✅ Emoji défini : ${emoji}`,
      ephemeral: true
    });
  }
}

// Handler pour les select menus
async function handleMotCacheSelect(interaction) {
  const config = await readConfig();
  const guildConfig = config.guilds[interaction.guildId] || {};
  const motCache = guildConfig.motCache || {};

  if (interaction.customId === 'motcache_select_mode') {
    const mode = interaction.values[0];
    motCache.mode = mode;
    guildConfig.motCache = motCache;
    await writeConfig(config);

    return interaction.update({
      content: `✅ Mode défini : **${mode === 'programmed' ? '📅 Programmé' : '🎲 Probabilité'}**`,
      components: []
    });
  }
}

module.exports = {
  handleMotCacheButton,
  handleMotCacheModal,
  handleMotCacheSelect
};
