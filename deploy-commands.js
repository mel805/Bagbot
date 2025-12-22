const { REST, Routes } = require('discord.js');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const allCommands = [];
const commandsPath = path.join(__dirname, 'src', 'commands');
const commandFiles = fs.readdirSync(commandsPath).filter(f => f.endsWith('.js'));

console.log('📦 Analyse des commandes...');
console.log('='.repeat(80));

for (const file of commandFiles) {
  const filePath = path.join(commandsPath, file);
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const command = require(filePath);
    
    if (!command.data) continue;
    
    const cmdData = command.data.toJSON();
    
    // Vérifier si la commande a dmPermission: true explicitement
    const hasDMPermission = content.includes('dmPermission: true') || 
                           content.includes('setDMPermission(true)');
    
    // FORCER dmPermission: false si pas explicitement true
    if (!hasDMPermission) {
      cmdData.dm_permission = false;
    }
    
    allCommands.push(cmdData);
    
    const dmStatus = hasDMPermission ? '(serveur + MP)' : '(serveur uniquement)';
    console.log(`  🌐 ${cmdData.name} ${dmStatus}`);
    
  } catch (error) {
    console.log(`  ⚠️  ${file} - Erreur: ${error.message}`);
  }
}

console.log('');
console.log('='.repeat(80));
console.log(`📊 Total: ${allCommands.length} commandes`);
console.log('   Toutes déployées en GLOBAL avec dm_permission contrôlé');
console.log('');

const rest = new REST().setToken(process.env.DISCORD_TOKEN);

(async () => {
  try {
    console.log('🚀 Déploiement GLOBAL de toutes les commandes...');
    console.log('');
    
    // Déployer TOUTES les commandes en global
    console.log(`📤 Déploiement de ${allCommands.length} commandes...`);
    await rest.put(
      Routes.applicationCommands(process.env.CLIENT_ID),
      { body: allCommands }
    );
    console.log('✅ Toutes les commandes déployées en GLOBAL');
    
    console.log('');
    console.log('🎉 Déploiement terminé !');
    console.log('');
    console.log(`📝 ${allCommands.length} commandes disponibles sur le serveur`);
    console.log('   (MP désactivé sauf pour celles avec dmPermission: true)');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur:', error);
    process.exit(1);
  }
})();
