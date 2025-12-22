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
console.log('');

const rest = new REST({ timeout: 60000 }).setToken(process.env.DISCORD_TOKEN);

// Fonction pour attendre
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

(async () => {
  try {
    console.log('🚀 Déploiement GLOBAL de toutes les commandes...');
    console.log('');
    
    let attempts = 0;
    const MAX_ATTEMPTS = 3;
    let success = false;
    
    while (!success && attempts < MAX_ATTEMPTS) {
      attempts++;
      console.log(`📤 Tentative ${attempts}/${MAX_ATTEMPTS} - Déploiement de ${allCommands.length} commandes...`);
      
      try {
        await rest.put(
          Routes.applicationCommands(process.env.CLIENT_ID),
          { body: allCommands }
        );
        success = true;
        console.log('✅ Toutes les commandes déployées en GLOBAL');
      } catch (error) {
        console.error(`❌ Erreur tentative ${attempts}:`, error.message);
        
        if (attempts < MAX_ATTEMPTS) {
          const waitTime = attempts * 5000; // 5s, 10s
          console.log(`⏳ Nouvelle tentative dans ${waitTime/1000}s...`);
          await wait(waitTime);
        } else {
          throw error;
        }
      }
    }
    
    console.log('');
    console.log('🎉 Déploiement terminé !');
    console.log('');
    console.log(`📝 ${allCommands.length} commandes disponibles sur le serveur`);
    console.log('   (MP désactivé sauf pour celles avec dmPermission: true)');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur finale:', error);
    process.exit(1);
  }
})();
