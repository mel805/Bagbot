const {
  SlashCommandBuilder,
  ActionRowBuilder,
  UserSelectMenuBuilder,
  ButtonBuilder,
  ButtonStyle,
  ModalBuilder,
  TextInputBuilder,
  TextInputStyle,
  EmbedBuilder,
} = require('discord.js');

// Simple in-memory wizard state (per user).
// Note: this intentionally avoids persistence; it's just a UI flow helper.
const sessions = new Map();
const SESSION_TTL_MS = 10 * 60 * 1000;

function now() { return Date.now(); }

function getSession(userId) {
  const s = sessions.get(userId);
  if (!s) return null;
  if (s.expiresAt && s.expiresAt < now()) {
    sessions.delete(userId);
    return null;
  }
  return s;
}

function upsertSession(userId, patch) {
  const current = getSession(userId) || { userId };
  const next = { ...current, ...patch, expiresAt: now() + SESSION_TTL_MS };
  sessions.set(userId, next);
  return next;
}

function buildEmbed(step, session) {
  const accused = session.accusedId ? `<@${session.accusedId}>` : '—';
  const lawyer = session.lawyerId ? `<@${session.lawyerId}>` : '—';
  const charge = session.charge ? session.charge : '—';

  const embed = new EmbedBuilder()
    .setColor(0x8e24aa)
    .setTitle('⚖️ Tribunal')
    .setDescription(
      step === 'accused' ? 'Choisis **l’accusé**.' :
      step === 'lawyer' ? 'Choisis **l’avocat** (optionnel).' :
      step === 'charge' ? 'Entre le **chef d’accusation**.' :
      step === 'confirm' ? 'Vérifie le récap et **valide**.' :
      'Suivi du dossier.'
    )
    .addFields(
      { name: 'Accusé', value: accused, inline: true },
      { name: 'Avocat', value: lawyer, inline: true },
      { name: 'Chef d’accusation', value: charge.length > 1024 ? charge.slice(0, 1021) + '…' : charge, inline: false },
    )
    .setFooter({ text: 'BAG • Tribunal' })
    .setTimestamp(new Date());

  return embed;
}

function rowCancel(ownerId) {
  return new ActionRowBuilder().addComponents(
    new ButtonBuilder()
      .setCustomId(`tribunal:cancel:${ownerId}`)
      .setLabel('Annuler')
      .setStyle(ButtonStyle.Secondary)
  );
}

function rowAccused(ownerId) {
  const select = new UserSelectMenuBuilder()
    .setCustomId(`tribunal:accused:${ownerId}`)
    .setPlaceholder('Sélectionner l’accusé…')
    .setMinValues(1)
    .setMaxValues(1);
  return [
    new ActionRowBuilder().addComponents(select),
    rowCancel(ownerId),
  ];
}

function rowLawyer(ownerId) {
  const select = new UserSelectMenuBuilder()
    .setCustomId(`tribunal:lawyer:${ownerId}`)
    .setPlaceholder('Sélectionner l’avocat (optionnel)…')
    .setMinValues(1)
    .setMaxValues(1);
  return [
    new ActionRowBuilder().addComponents(select),
    new ActionRowBuilder().addComponents(
      new ButtonBuilder()
        .setCustomId(`tribunal:skip_lawyer:${ownerId}`)
        .setLabel('Sans avocat')
        .setStyle(ButtonStyle.Secondary),
      new ButtonBuilder()
        .setCustomId(`tribunal:enter_charge:${ownerId}`)
        .setLabel('Entrer accusation')
        .setStyle(ButtonStyle.Primary),
    ),
    rowCancel(ownerId),
  ];
}

function rowCharge(ownerId) {
  return [
    new ActionRowBuilder().addComponents(
      new ButtonBuilder()
        .setCustomId(`tribunal:enter_charge:${ownerId}`)
        .setLabel('Entrer chef d’accusation')
        .setStyle(ButtonStyle.Primary),
    ),
    rowCancel(ownerId),
  ];
}

function rowConfirm(ownerId) {
  return [
    new ActionRowBuilder().addComponents(
      new ButtonBuilder()
        .setCustomId(`tribunal:confirm:${ownerId}`)
        .setLabel('Valider')
        .setStyle(ButtonStyle.Success),
      new ButtonBuilder()
        .setCustomId(`tribunal:cancel:${ownerId}`)
        .setLabel('Annuler')
        .setStyle(ButtonStyle.Secondary),
    )
  ];
}

function ensureOwner(interaction, ownerId) {
  if (interaction.user.id !== ownerId) {
    // Do not leak flow state to others.
    try { interaction.reply({ content: '⛔ Ce menu ne vous appartient pas.', ephemeral: true }); } catch (_) {}
    return false;
  }
  return true;
}

module.exports = {
  name: 'tribunal',

  data: new SlashCommandBuilder()
    .setName('tribunal')
    .setDescription('⚖️ Ouvrir un dossier au tribunal')
    .setDMPermission(false),

  async execute(interaction) {
    const ownerId = interaction.user.id;
    upsertSession(ownerId, { step: 'accused', accusedId: null, lawyerId: null, charge: '' });
    const embed = buildEmbed('accused', getSession(ownerId) || {});
    return interaction.reply({ embeds: [embed], components: rowAccused(ownerId), ephemeral: true });
  },

  async handleInteraction(interaction) {
    try {
      // Buttons
      if (interaction.isButton() && typeof interaction.customId === 'string' && interaction.customId.startsWith('tribunal:')) {
        const [, action, ownerId] = interaction.customId.split(':');
        if (!ownerId || !ensureOwner(interaction, ownerId)) return true;

        if (action === 'cancel') {
          sessions.delete(ownerId);
          try { await interaction.update({ content: '✅ Tribunal annulé.', embeds: [], components: [] }); } catch (_) {}
          return true;
        }

        if (action === 'skip_lawyer') {
          const s = upsertSession(ownerId, { lawyerId: null, step: 'charge' });
          const embed = buildEmbed('charge', s);
          try { await interaction.update({ embeds: [embed], components: rowCharge(ownerId) }); } catch (_) {}
          return true;
        }

        if (action === 'enter_charge') {
          const modal = new ModalBuilder()
            .setCustomId(`tribunal:charge_modal:${ownerId}`)
            .setTitle('Chef d’accusation');
          const input = new TextInputBuilder()
            .setCustomId('charge')
            .setLabel('Chef d’accusation')
            .setStyle(TextInputStyle.Paragraph)
            .setRequired(true)
            .setMaxLength(900)
            .setPlaceholder('Ex: Vol de cookies, spam, trahison…');
          modal.addComponents(new ActionRowBuilder().addComponents(input));
          await interaction.showModal(modal);
          return true;
        }

        if (action === 'confirm') {
          const s = getSession(ownerId);
          if (!s || !s.accusedId) {
            try { await interaction.reply({ content: '❌ Session expirée. Relance `/tribunal`.', ephemeral: true }); } catch (_) {}
            return true;
          }
          const embed = new EmbedBuilder()
            .setColor(0xd81b60)
            .setTitle('⚖️ Dossier au Tribunal')
            .addFields(
              { name: 'Accusé', value: `<@${s.accusedId}>`, inline: true },
              { name: 'Avocat', value: s.lawyerId ? `<@${s.lawyerId}>` : 'Aucun', inline: true },
              { name: 'Chef d’accusation', value: s.charge || '—', inline: false },
              { name: 'Plaignant', value: `<@${ownerId}>`, inline: true },
            )
            .setFooter({ text: 'BAG • Tribunal' })
            .setTimestamp(new Date());

          // Post the case in the current channel (public), then close the wizard.
          try { await interaction.channel.send({ embeds: [embed] }); } catch (_) {}
          sessions.delete(ownerId);
          try { await interaction.update({ content: '✅ Dossier envoyé au tribunal.', embeds: [], components: [] }); } catch (_) {}
          return true;
        }

        return false;
      }

      // Select menus
      if (interaction.isUserSelectMenu() && typeof interaction.customId === 'string' && interaction.customId.startsWith('tribunal:')) {
        const [, kind, ownerId] = interaction.customId.split(':');
        if (!ownerId || !ensureOwner(interaction, ownerId)) return true;
        const picked = interaction.values?.[0];
        if (!picked) return true;

        if (kind === 'accused') {
          const s = upsertSession(ownerId, { accusedId: picked, step: 'lawyer' });
          const embed = buildEmbed('lawyer', s);
          try { await interaction.update({ embeds: [embed], components: rowLawyer(ownerId) }); } catch (_) {}
          return true;
        }

        if (kind === 'lawyer') {
          const s = upsertSession(ownerId, { lawyerId: picked, step: 'charge' });
          const embed = buildEmbed('charge', s);
          try { await interaction.update({ embeds: [embed], components: rowCharge(ownerId) }); } catch (_) {}
          return true;
        }

        return false;
      }

      // Modal submit
      if (interaction.isModalSubmit() && typeof interaction.customId === 'string' && interaction.customId.startsWith('tribunal:charge_modal:')) {
        const ownerId = interaction.customId.split(':')[2];
        if (!ownerId || !ensureOwner(interaction, ownerId)) return true;
        const charge = String(interaction.fields.getTextInputValue('charge') || '').trim();
        const s = upsertSession(ownerId, { charge, step: 'confirm' });
        const embed = buildEmbed('confirm', s);
        try { await interaction.reply({ embeds: [embed], components: rowConfirm(ownerId), ephemeral: true }); } catch (_) {}
        return true;
      }

      return false;
    } catch (e) {
      try {
        const msg = `❌ Une erreur est survenue : ${e?.message || String(e)}`;
        if (interaction.deferred || interaction.replied) await interaction.followUp({ content: msg, ephemeral: true });
        else await interaction.reply({ content: msg, ephemeral: true });
      } catch (_) {}
      return true;
    }
  }
};

