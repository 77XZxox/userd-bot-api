process.removeAllListeners('warning');
const Discord = require('discord.js');
const config = require('./config.json');

const client = new Discord.Client({ 
    intents: [
        'GUILDS', 
        'GUILD_MESSAGES', 
        'GUILD_MEMBERS'
    ],
    fetchAllMembers: true 
});

const staffRoles = Array.isArray(config.rolestaff) ? config.rolestaff : [config.rolestaff];

client.on('ready', () => {
    console.log(`[USERD] ${config.nameserver} est connectée à l'API`);
});

client.on('error', err => console.error('[Discord Client Error]', err));
client.on('shardError', err => console.error('[Websocket Error]', err));

async function executeCommandOnServer(consoleCommand) {
    try {
        if (global.exports['BotAPI'] && global.exports['BotAPI'].Execute) {
            const result = await global.exports['BotAPI'].Execute(consoleCommand);
            return { success: true, output: result || 'OK' };
        }
        return { success: false, output: "Export 'BotAPI' introuvable." };
    } catch (err) {
        return { success: false, output: err.message || err };
    }
}

const eventName = Discord.version.startsWith('12') ? 'message' : 'messageCreate';

client.on(eventName, async (msg) => {
    if (!msg.guild || msg.author.bot || !msg.content.startsWith('+')) return;

    const args = msg.content.slice(1).trim().split(/ +/);
    const command = args.shift().toLowerCase();
    if (command === 'execute') {
        const memberRoles = msg.member ? (msg.member.roles.cache || msg.member.roles) : null;
        if (!memberRoles || !staffRoles.some(roleId => memberRoles.has(roleId))) {
            return msg.channel.send("Permission refusée ou introuvable.");
        }

        if (args.length === 0) return msg.channel.send('Usage: `+execute commande`');

        const consoleCommand = args.join(" ");

        executeCommandOnServer(consoleCommand).then(async (res) => {
            
            if (res.success) {
                msg.channel.send(`La commande a été exécutée avec succès : ${consoleCommand}`).catch(() => {});
            } else {
                msg.channel.send(`Erreur : ${res.output}`).catch(() => {});
            }

            if (config.logChannelID) {
                try {
                    const channels = msg.guild.channels.cache || msg.guild.channels;
                    const logChannel = channels ? channels.get(config.logChannelID) : null;

                    if (logChannel) {
                        const logEmbed = new Discord.MessageEmbed()
                            .setColor(res.success ? '#00ff00' : '#ff0000')
                            .setTitle('Log Commande')
                            .addField('Staff', msg.author.tag, true)
                            .addField('Statut', res.success ? '✅ Réussi' : '❌ Échoué', true)
                            .addField('Commande', `\`\`\`${consoleCommand}\`\`\``, false)
                            .setTimestamp();

                        logChannel.send({ embeds: [logEmbed] }).catch(() => logChannel.send(logEmbed));
                    }
                } catch (e) {
                    console.error("Erreur logs:", e.message);
                }
            }
        }).catch(err => console.error(err));
    }
});

client.login(config.token).catch(err => console.error('[Discord LOGIN ERROR]', err));