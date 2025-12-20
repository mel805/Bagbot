package com.bagbot.manager.ui.screens.config

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.EmojiPeople
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.bagbot.manager.ApiClient
import com.bagbot.manager.ui.components.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.*

@Composable
fun WelcomeConfigScreen(
    api: ApiClient,
    channels: Map<String, String>,
    json: Json
) {
    var enabled by remember { mutableStateOf(false) }
    var channelId by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var embedEnabled by remember { mutableStateOf(false) }
    var embedTitle by remember { mutableStateOf("") }
    var embedDescription by remember { mutableStateOf("") }
    var embedColor by remember { mutableStateOf("") }
    var embedFooter by remember { mutableStateOf("") }
    var sendEmbedInDM by remember { mutableStateOf(false) }
    var isLoading by remember { mutableStateOf(true) }
    
    LaunchedEffect(Unit) {
        isLoading = true
        withContext(Dispatchers.IO) {
            try {
                val response = api.getJson("/api/configs/welcome")
                val data = json.parseToJsonElement(response).jsonObject
                withContext(Dispatchers.Main) {
                    enabled = data["enabled"]?.jsonPrimitive?.booleanOrNull ?: false
                    channelId = data["channelId"]?.jsonPrimitive?.contentOrNull ?: ""
                    message = data["message"]?.jsonPrimitive?.contentOrNull ?: ""
                    embedEnabled = data["embedEnabled"]?.jsonPrimitive?.booleanOrNull ?: false
                    embedTitle = data["embedTitle"]?.jsonPrimitive?.contentOrNull ?: ""
                    embedDescription = data["embedDescription"]?.jsonPrimitive?.contentOrNull ?: ""
                    embedColor = data["embedColor"]?.jsonPrimitive?.contentOrNull ?: ""
                    embedFooter = data["embedFooter"]?.jsonPrimitive?.contentOrNull ?: ""
                    sendEmbedInDM = data["sendEmbedInDM"]?.jsonPrimitive?.booleanOrNull ?: false
                }
            } catch (e: Exception) {
                // Handle error
            } finally {
                withContext(Dispatchers.Main) {
                    isLoading = false
                }
            }
        }
    }
    
    if (isLoading) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = androidx.compose.ui.Alignment.Center
        ) {
            androidx.compose.material3.CircularProgressIndicator()
        }
        return
    }
    
    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            ConfigSection(
                title = "👋 Messages de bienvenue",
                icon = Icons.Default.EmojiPeople,
                color = Color(0xFF4CAF50),
                onSave = {
                    withContext(Dispatchers.IO) {
                        try {
                            val updates = buildJsonObject {
                                put("enabled", enabled)
                                put("channelId", channelId)
                                put("message", message)
                                put("embedEnabled", embedEnabled)
                                put("embedTitle", embedTitle)
                                put("embedDescription", embedDescription)
                                put("embedColor", embedColor)
                                put("embedFooter", embedFooter)
                                put("sendEmbedInDM", sendEmbedInDM)
                            }
                            api.putJson("/api/configs/welcome", updates.toString())
                            Result.success("✅ Configuration sauvegardée avec succès")
                        } catch (e: Exception) {
                            Result.failure(e)
                        }
                    }
                }
            ) {
                ConfigSwitch(
                    label = "Système activé",
                    checked = enabled,
                    onCheckedChange = { enabled = it }
                )
                
                Spacer(Modifier.height(16.dp))
                
                ChannelSelector(
                    channels = channels,
                    selectedChannelId = channelId,
                    onChannelSelected = { channelId = it },
                    label = "Salon de bienvenue"
                )
                
                Spacer(Modifier.height(16.dp))
                
                ConfigTextField(
                    label = "Message de bienvenue",
                    value = message,
                    onValueChange = { message = it },
                    placeholder = "Bienvenue {user} sur le serveur !",
                    multiline = true
                )
                
                Spacer(Modifier.height(16.dp))
                
                ConfigSwitch(
                    label = "Activer l'embed",
                    checked = embedEnabled,
                    onCheckedChange = { embedEnabled = it }
                )
                
                if (embedEnabled) {
                    Spacer(Modifier.height(16.dp))
                    
                    ConfigTextField(
                        label = "Titre de l'embed",
                        value = embedTitle,
                        onValueChange = { embedTitle = it },
                        placeholder = "Bienvenue !"
                    )
                    
                    Spacer(Modifier.height(16.dp))
                    
                    ConfigTextField(
                        label = "Description de l'embed",
                        value = embedDescription,
                        onValueChange = { embedDescription = it },
                        placeholder = "Nous sommes ravis de t'accueillir !",
                        multiline = true
                    )
                    
                    Spacer(Modifier.height(16.dp))
                    
                    ConfigTextField(
                        label = "Couleur de l'embed (hex)",
                        value = embedColor,
                        onValueChange = { embedColor = it },
                        placeholder = "#4CAF50"
                    )
                    
                    Spacer(Modifier.height(16.dp))
                    
                    ConfigTextField(
                        label = "Footer de l'embed",
                        value = embedFooter,
                        onValueChange = { embedFooter = it },
                        placeholder = "Serveur BAG Bot"
                    )
                    
                    Spacer(Modifier.height(16.dp))
                    
                    ConfigSwitch(
                        label = "Envoyer l'embed en DM",
                        checked = sendEmbedInDM,
                        onCheckedChange = { sendEmbedInDM = it }
                    )
                }
            }
        }
    }
}
