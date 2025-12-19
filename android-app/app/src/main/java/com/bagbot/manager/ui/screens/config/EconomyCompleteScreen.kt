package com.bagbot.manager.ui.screens.config

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bagbot.manager.ApiClient
import com.bagbot.manager.ui.components.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.*

@Composable
fun EconomyCompleteScreen(
    configData: JsonObject?,
    api: ApiClient,
    json: Json,
    scope: CoroutineScope,
    snackbar: SnackbarHostState,
    members: Map<String, String>,
    onBack: () -> Unit
) {
    var selectedTab by remember { mutableStateOf(0) }
    val economyData = configData?.get("economy")?.jsonObject
    
    // Debug log
    LaunchedEffect(configData, economyData) {
        android.util.Log.d("ECONOMY_DEBUG", "configData is null: ${configData == null}")
        android.util.Log.d("ECONOMY_DEBUG", "economyData is null: ${economyData == null}")
        if (configData != null) {
            android.util.Log.d("ECONOMY_DEBUG", "configData keys: ${configData.keys.joinToString()}")
        }
        if (economyData != null) {
            android.util.Log.d("ECONOMY_DEBUG", "economyData keys: ${economyData.keys.joinToString()}")
        }
    }
    
    Column(Modifier.fillMaxSize()) {
        // Header avec bouton retour
        Row(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Default.ArrowBack, "Retour")
            }
            Spacer(Modifier.width(8.dp))
            Text("💰 Économie", style = MaterialTheme.typography.headlineMedium)
        }
        
        // Tabs
        ScrollableTabRow(
            selectedTabIndex = selectedTab,
            containerColor = Color(0xFF1E1E1E),
            edgePadding = 0.dp
        ) {
            Tab(selected = selectedTab == 0, onClick = { selectedTab = 0 }, text = { Text("👥 Users") })
            Tab(selected = selectedTab == 1, onClick = { selectedTab = 1 }, text = { Text("⚙️ Settings") })
            Tab(selected = selectedTab == 2, onClick = { selectedTab = 2 }, text = { Text("🛒 Boutique") })
            Tab(selected = selectedTab == 3, onClick = { selectedTab = 3 }, text = { Text("⏱️ Cooldowns") })
            Tab(selected = selectedTab == 4, onClick = { selectedTab = 4 }, text = { Text("🎬 Actions") })
            Tab(selected = selectedTab == 5, onClick = { selectedTab = 5 }, text = { Text("☯️ Karma") })
            Tab(selected = selectedTab == 6, onClick = { selectedTab = 6 }, text = { Text("🏆 Classement") })
        }
        
        // Content
        when (selectedTab) {
            0 -> EconomyUsersTab(economyData, members, api, json, scope, snackbar)
            1 -> EconomySettingsTab(economyData, api, json)
            2 -> EconomyShopTab(economyData, api, json)
            3 -> EconomyCooldownsTab(economyData, api, json)
            4 -> EconomyActionsTab(economyData, api, json)
            5 -> EconomyKarmaTab(economyData, api, json, members)
            6 -> EconomyLeaderboardTab(economyData, members)
        }
    }
}

@Composable
fun EconomyUsersTab(
    economyData: JsonObject?,
    members: Map<String, String>,
    api: ApiClient,
    json: Json,
    scope: CoroutineScope,
    snackbar: SnackbarHostState
) {
    val balances = economyData?.get("balances")?.jsonObject ?: JsonObject(emptyMap())
    val sortedUsers = remember(balances, members) {
        balances.entries.map { (userId, data) ->
            val obj = data.jsonObject
            Triple(
                userId,
                obj["coins"]?.jsonPrimitive?.intOrNull ?: 0,
                obj
            )
        }.sortedByDescending { it.second }
    }
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        item {
            Text(
                "Utilisateurs (${sortedUsers.size})",
                style = MaterialTheme.typography.titleLarge
            )
            Spacer(Modifier.height(8.dp))
        }
        
        itemsIndexed(sortedUsers) { index, (userId, coins, data) ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF2A2A2A))
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            "#${index + 1} ${members[userId] ?: "Inconnu"}",
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            "$coins 💎",
                            color = Color(0xFF57F287),
                            fontSize = 18.sp
                        )
                        val charme = data["charme"]?.jsonPrimitive?.intOrNull
                        val perv = data["perv"]?.jsonPrimitive?.intOrNull
                        if (charme != null || perv != null) {
                            Text(
                                "Charme: ${charme ?: 0} | Perv: ${perv ?: 0}",
                                fontSize = 12.sp,
                                color = Color.Gray
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun EconomySettingsTab(
    economyData: JsonObject?,
    api: ApiClient,
    json: Json
) {
    var enabled by remember { mutableStateOf(economyData?.get("enabled")?.jsonPrimitive?.booleanOrNull ?: false) }
    val settings = economyData?.get("settings")?.jsonObject
    var startCoins by remember { mutableStateOf(settings?.get("startCoins")?.jsonPrimitive?.intOrNull ?: 100) }
    var dailyAmount by remember { mutableStateOf(settings?.get("dailyAmount")?.jsonPrimitive?.intOrNull ?: 50) }
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            ConfigSection(
                title = "Paramètres Généraux",
                icon = Icons.Default.Settings,
                color = Color(0xFF57F287),
                onSave = {
                    withContext(Dispatchers.IO) {
                        try {
                            val updates = buildJsonObject {
                                put("enabled", enabled)
                                putJsonObject("settings") {
                                    put("startCoins", startCoins)
                                    put("dailyAmount", dailyAmount)
                                }
                            }
                            api.putJson("/api/configs/economy", updates.toString())
                            Result.success("✅ Sauvegardé")
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
                ConfigNumberField(
                    label = "💎 Coins de départ",
                    value = startCoins,
                    onValueChange = { startCoins = it }
                )
                ConfigNumberField(
                    label = "📅 Daily (coins/jour)",
                    value = dailyAmount,
                    onValueChange = { dailyAmount = it }
                )
            }
        }
    }
}

@Composable
fun EconomyShopTab(economyData: JsonObject?, api: ApiClient, json: Json) {
    val shopItems = economyData?.get("shop")?.jsonObject?.get("items")?.jsonArray ?: JsonArray(emptyList())
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text("🛒 Boutique (${shopItems.size} articles)", style = MaterialTheme.typography.titleLarge)
        }
        
        items(shopItems.size) { index ->
            val item = shopItems[index].jsonObject
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF2A2A2A))
            ) {
                Column(Modifier.padding(16.dp)) {
                    Text(
                        item["name"]?.jsonPrimitive?.contentOrNull ?: "Article",
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        "Prix: ${item["price"]?.jsonPrimitive?.intOrNull ?: 0} 💎",
                        color = Color(0xFF57F287)
                    )
                }
            }
        }
        
        if (shopItems.isEmpty()) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF2A2A2A))
                ) {
                    Box(
                        Modifier.fillMaxWidth().padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Aucun article dans la boutique", color = Color.Gray)
                    }
                }
            }
        }
    }
}

@Composable
fun EconomyCooldownsTab(economyData: JsonObject?, api: ApiClient, json: Json) {
    val cooldowns = economyData?.get("settings")?.jsonObject?.get("cooldowns")?.jsonObject ?: JsonObject(emptyMap())
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text("⏱️ Cooldowns", style = MaterialTheme.typography.titleLarge)
        }
        
        cooldowns.forEach { (action, cooldownMs) ->
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF2A2A2A))
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(action, fontWeight = FontWeight.Bold)
                        Text(
                            "${cooldownMs.jsonPrimitive.longOrNull?.div(1000) ?: 0}s",
                            color = Color(0xFF57F287)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun EconomyActionsTab(economyData: JsonObject?, api: ApiClient, json: Json) {
    val actionsConfig = economyData?.get("actions")?.jsonObject?.get("config")?.jsonObject ?: JsonObject(emptyMap())
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text("🎬 Configuration Actions", style = MaterialTheme.typography.titleLarge)
        }
        
        actionsConfig.forEach { (action, config) ->
            item {
                val actionData = config.jsonObject
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF2A2A2A))
                ) {
                    Column(Modifier.padding(16.dp)) {
                        Text(action, fontWeight = FontWeight.Bold)
                        Text(
                            "Coût: ${actionData["cost"]?.jsonPrimitive?.intOrNull ?: 0} 💎",
                            color = Color(0xFF57F287)
                        )
                        Text(
                            "Chance: ${actionData["successRate"]?.jsonPrimitive?.intOrNull ?: 50}%",
                            color = Color.Gray,
                            fontSize = 12.sp
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun EconomyKarmaTab(economyData: JsonObject?, api: ApiClient, json: Json, members: Map<String, String>) {
    val balances = economyData?.get("balances")?.jsonObject ?: JsonObject(emptyMap())
    val usersWithKarma = remember(balances) {
        balances.entries.mapNotNull { (userId, data) ->
            val obj = data.jsonObject
            val charme = obj["charme"]?.jsonPrimitive?.intOrNull ?: 0
            val perv = obj["perv"]?.jsonPrimitive?.intOrNull ?: 0
            if (charme > 0 || perv > 0) Triple(userId, charme, perv) else null
        }.sortedByDescending { it.second + it.third }
    }
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        item {
            Text("☯️ Karma (${usersWithKarma.size} utilisateurs)", style = MaterialTheme.typography.titleLarge)
        }
        
        items(usersWithKarma) { (userId, charme, perv) ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF2A2A2A))
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(members[userId] ?: "Inconnu", modifier = Modifier.weight(1f))
                    Column(horizontalAlignment = Alignment.End) {
                        Text("😇 $charme", color = Color(0xFF57F287))
                        Text("😈 $perv", color = Color(0xFFED4245))
                    }
                }
            }
        }
    }
}

@Composable
fun EconomyLeaderboardTab(economyData: JsonObject?, members: Map<String, String>) {
    val balances = economyData?.get("balances")?.jsonObject ?: JsonObject(emptyMap())
    val sorted = remember(balances) {
        balances.entries.map { (userId, data) ->
            userId to (data.jsonObject["coins"]?.jsonPrimitive?.intOrNull ?: 0)
        }.sortedByDescending { it.second }
    }
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text("🏆 Classement Économie", style = MaterialTheme.typography.titleLarge)
        }
        
        itemsIndexed(sorted) { index, (userId, coins) ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = when (index) {
                        0 -> Color(0xFFFFD700).copy(alpha = 0.2f)
                        1 -> Color(0xFFC0C0C0).copy(alpha = 0.2f)
                        2 -> Color(0xFFCD7F32).copy(alpha = 0.2f)
                        else -> Color(0xFF2A2A2A)
                    }
                )
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.weight(1f)) {
                        Text(
                            "#${index + 1}",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = when (index) {
                                0 -> Color(0xFFFFD700)
                                1 -> Color(0xFFC0C0C0)
                                2 -> Color(0xFFCD7F32)
                                else -> Color.White
                            }
                        )
                        Spacer(Modifier.width(16.dp))
                        Text(members[userId] ?: "Inconnu", modifier = Modifier.weight(1f))
                    }
                    Text(
                        "$coins 💎",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF57F287)
                    )
                }
            }
        }
    }
}
