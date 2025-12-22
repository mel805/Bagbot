const { REST, Routes } = require('discord.js');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const allCommands = [];
const commandsPath = path.join(__dirname, 'src', 'commands');
const commandFiles = fs.readdirSync(commandsPath).filter(f => f.endsWith('.js'));

console.log('📦 Chargement des commandes...');

for (const file of commandFiles) {
  const filePath = path.join(commandsPath, file);
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const command = require(filePath);
    
    if (!command.data) continue;
    
    const cmdData = command.data.toJSON();
    const hasDMPermission = content.includes('dmPermission: true') || content.includes('setDMPermission(true)');
    if (!hasDMPermission) cmdData.dm_permission = false;
    
    allCommands.push(cmdData);
  } catch (error) {
    console.log(`  ⚠️  ${file} - ${error.message}`);
  }
}

console.log(`✅ ${allCommands.length} commandes chargées`);
console.log('');

const rest = new REST({ timeout: 30000 }).setToken(process.env.DISCORD_TOKEN);
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

(async () => {
  try {
    console.log('🚀 Déploiement GLOBAL agressif avec retries...');
    console.log('');
    
    let attempt = 0;
    const MAX_ATTEMPTS = 10;
    let lastError = null;
    
    while (attempt < MAX_ATTEMPTS) {
      attempt++;
      const waitTime = Math.min(attempt * 2000, 30000); // 2s, 4s, 6s... max 30s
      
      console.log(`📤 Tentative ${attempt}/${MAX_ATTEMPTS}...`);
      
      try {
        await rest.put(
          Routes.applicationCommands(process.env.CLIENT_ID),
          { body: allCommands }
        );
        
        console.log('');
        console.log('🎉 ✅ TOUTES LES COMMANDES DÉPLOYÉES !');
        console.log(`📝 ${allCommands.length} commandes disponibles`);
        console.log('');
        process.exit(0);
        
      } catch (error) {
        lastError = error;
        
        if (error.status === 429 || error.code === 'RATE_LIMITED') {
          const retryAfter = error.retryAfter || waitTime;
          console.log(`  ⏳ Rate limited - attente ${Math.ceil(retryAfter/1000)}s...`);
          await wait(retryAfter);
        } else if (error.code === 50035) {
          console.log(`  ⚠️  Erreur validation Discord`);
          await wait(waitTime);
        } else {
          console.log(`  ❌ ${error.message}`);
          await wait(waitTime);
        }
        
        if (attempt < MAX_ATTEMPTS) {
          console.log(`  🔄 Nouvelle tentative dans ${waitTime/1000}s...`);
          await wait(waitTime);
        }
      }
    }
    
    console.log('');
    console.log('❌ Échec après 10 tentatives');
    console.log(`Dernière erreur: ${lastError?.message}`);
    process.exit(1);
    
  } catch (error) {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  }
})();
