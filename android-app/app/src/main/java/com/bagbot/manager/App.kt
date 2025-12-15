package com.bagbot.manager

import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun App(deepLink: Uri?, onDeepLinkConsumed: () -> Unit) {
  val scope = rememberCoroutineScope()
  val snackbar = remember { SnackbarHostState() }

  val store = remember { SettingsStore() }
  val api = remember { ApiClient(store) }

  val baseUrl = remember { mutableStateOf(store.getBaseUrl()) }
  val token = remember { mutableStateOf(store.getToken()) }

  val statusJson = remember { mutableStateOf<String?>(null) }
  val configJson = remember { mutableStateOf<String?>(null) } // full guild config JSON
  val configEdit = remember { mutableStateOf("") }
  val busy = remember { mutableStateOf(false) }
  val tab = remember { mutableStateOf(0) } // 0 Home, 1 Economy, 2 Inactivity, 3 Welcome, 4 Config

  val json = remember { Json { ignoreUnknownKeys = true } }

  fun currentConfigObject(): JsonObject? {
    val s = configJson.value ?: return null
    return try { json.parseToJsonElement(s).jsonObject } catch (_: Exception) { null }
  }

  // Handle deep link: bagbot://auth?token=...
  LaunchedEffect(deepLink) {
    if (deepLink == null) return@LaunchedEffect
    val t = deepLink.getQueryParameter("token")
    if (!t.isNullOrBlank()) {
      store.setToken(t.trim())
      token.value = t.trim()
      snackbar.showSnackbar("Connecté (token reçu)")
      onDeepLinkConsumed()
    }
  }

  fun login() {
    val url = baseUrl.value.trim().removeSuffix("/")
    if (url.isBlank()) {
      scope.launch { snackbar.showSnackbar("Renseigne l'URL du dashboard (ex: http://192.168.0.10:33002)") }
      return
    }
    store.setBaseUrl(url)
    baseUrl.value = url
    // Open browser to server-driven OAuth flow (server will deep-link back).
    val authUrl = "$url/auth/mobile/start?app_redirect=bagbot://auth"
    ExternalBrowser.open(authUrl)
  }

  fun refreshAll() {
    scope.launch {
      busy.value = true
      try {
        statusJson.value = api.getJson("/api/bot/status")
        configJson.value = api.getJson("/api/configs")
        configEdit.value = configJson.value ?: ""
      } catch (e: Exception) {
        snackbar.showSnackbar("Erreur: ${e.message}")
      } finally {
        busy.value = false
      }
    }
  }

  fun saveFullConfig(newConfigJson: String) {
    scope.launch {
      busy.value = true
      try {
        JsonUtil.parseObject(newConfigJson)
        api.putJson("/api/configs", newConfigJson)
        configJson.value = newConfigJson
        configEdit.value = newConfigJson
        snackbar.showSnackbar("Config sauvegardée")
      } catch (e: Exception) {
        snackbar.showSnackbar("Erreur: ${e.message}")
      } finally {
        busy.value = false
      }
    }
  }

  LaunchedEffect(token.value, baseUrl.value) {
    if (!token.value.isNullOrBlank() && !baseUrl.value.isNullOrBlank()) {
      refreshAll()
    }
  }

  Scaffold(
    topBar = { TopAppBar(title = { Text("BAG Bot Manager") }) },
    bottomBar = {
      if (!token.value.isNullOrBlank()) {
        NavigationBar {
          NavigationBarItem(
            selected = tab.value == 0,
            onClick = { tab.value = 0 },
            icon = { Icon(Icons.Default.Home, contentDescription = "Accueil") },
            label = { Text("Accueil") }
          )
          NavigationBarItem(
            selected = tab.value == 1,
            onClick = { tab.value = 1 },
            icon = { Icon(Icons.Default.ShoppingCart, contentDescription = "Éco") },
            label = { Text("Éco") }
          )
          NavigationBarItem(
            selected = tab.value == 2,
            onClick = { tab.value = 2 },
            icon = { Icon(Icons.Default.Build, contentDescription = "Inactivité") },
            label = { Text("Inactivité") }
          )
          NavigationBarItem(
            selected = tab.value == 3,
            onClick = { tab.value = 3 },
            icon = { Icon(Icons.Default.Notifications, contentDescription = "Welcome") },
            label = { Text("Welcome") }
          )
          NavigationBarItem(
            selected = tab.value == 4,
            onClick = { tab.value = 4 },
            icon = { Icon(Icons.Default.Settings, contentDescription = "Config") },
            label = { Text("Config") }
          )
        }
      }
    },
    snackbarHost = { SnackbarHost(snackbar) }
  ) { padding ->
    Column(
      modifier = Modifier
        .padding(padding)
        .padding(16.dp)
        .verticalScroll(rememberScrollState()),
      verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
      Card(Modifier.fillMaxWidth()) {
        Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
          Text("Connexion", style = MaterialTheme.typography.titleMedium)
          OutlinedTextField(
            value = baseUrl.value,
            onValueChange = { baseUrl.value = it },
            label = { Text("URL Dashboard") },
            placeholder = { Text("http://IP_FREEBOX:33002") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
          )
          Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Button(onClick = { login() }) { Text("Connexion Discord") }
            Button(onClick = {
              store.setToken("")
              token.value = ""
              snackbar.currentSnackbarData?.dismiss()
              scope.launch { snackbar.showSnackbar("Déconnecté") }
            }) { Text("Déconnexion") }
          }
          Text(
            "Statut: " + if (token.value.isNullOrBlank()) "non connecté" else "connecté",
            style = MaterialTheme.typography.bodyMedium
          )
          Text(
            "Note: la connexion s'ouvre dans le navigateur (OAuth).",
            style = MaterialTheme.typography.bodySmall
          )
        }
      }

      if (busy.value) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
          CircularProgressIndicator()
        }
      }

      if (!token.value.isNullOrBlank()) {
        when (tab.value) {
          0 -> {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
              Button(onClick = { refreshAll() }) { Text("Rafraîchir") }
              Button(onClick = {
                scope.launch {
                  busy.value = true
                  try {
                    api.postJson("/bot/control", """{"action":"restart"}""")
                    snackbar.showSnackbar("Restart envoyé")
                  } catch (e: Exception) {
                    snackbar.showSnackbar("Erreur: ${e.message}")
                  } finally {
                    busy.value = false
                  }
                }
              }) { Text("Restart bot") }
              Button(onClick = {
                scope.launch {
                  busy.value = true
                  try {
                    api.postJson("/backup", "{}")
                    snackbar.showSnackbar("Backup créé")
                  } catch (e: Exception) {
                    snackbar.showSnackbar("Erreur: ${e.message}")
                  } finally {
                    busy.value = false
                  }
                }
              }) { Text("Backup") }
            }

            Spacer(Modifier.height(6.dp))

            Card(Modifier.fillMaxWidth()) {
              Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Bot status", style = MaterialTheme.typography.titleMedium)
                Text(
                  statusJson.value ?: "—",
                  fontFamily = FontFamily.Monospace,
                  style = MaterialTheme.typography.bodySmall
                )
              }
            }
          }

          1 -> {
            val cfg = currentConfigObject()
            val economy = cfg?.get("economy")?.jsonObject
            val currency = economy?.get("currency")?.jsonObject
            val settings = economy?.get("settings")?.jsonObject

            val currencyName = remember(configJson.value) { mutableStateOf(currency?.get("name")?.jsonPrimitive?.contentOrNull ?: "BAG$") }
            val emoji = remember(configJson.value) { mutableStateOf(settings?.get("emoji")?.jsonPrimitive?.contentOrNull ?: "💰") }

            Card(Modifier.fillMaxWidth()) {
              Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Économie", style = MaterialTheme.typography.titleMedium)
                OutlinedTextField(
                  value = currencyName.value,
                  onValueChange = { currencyName.value = it },
                  label = { Text("Nom monnaie") },
                  singleLine = true,
                  modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                  value = emoji.value,
                  onValueChange = { emoji.value = it },
                  label = { Text("Emoji") },
                  singleLine = true,
                  modifier = Modifier.fillMaxWidth()
                )

                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                  Button(onClick = {
                    val root = cfg?.toMutableMap() ?: mutableMapOf()
                    val ecoMap = (root["economy"] as? JsonObject)?.toMutableMap() ?: mutableMapOf()
                    val curMap = (ecoMap["currency"] as? JsonObject)?.toMutableMap() ?: mutableMapOf()
                    val setMap = (ecoMap["settings"] as? JsonObject)?.toMutableMap() ?: mutableMapOf()
                    curMap["name"] = JsonPrimitive(currencyName.value)
                    setMap["emoji"] = JsonPrimitive(emoji.value)
                    ecoMap["currency"] = JsonObject(curMap)
                    ecoMap["settings"] = JsonObject(setMap)
                    root["economy"] = JsonObject(ecoMap)
                    val newJson = Json { prettyPrint = true }.encodeToString(kotlinx.serialization.json.JsonObject.serializer(), JsonObject(root))
                    saveFullConfig(newJson)
                  }) { Text("Sauvegarder") }
                  Button(onClick = { refreshAll() }) { Text("Recharger") }
                }
              }
            }
          }

          2 -> {
            val cfg = currentConfigObject()
            val autokick = cfg?.get("autokick")?.jsonObject
            val inactivityKick = autokick?.get("inactivityKick")?.jsonObject
            val enabled = remember(configJson.value) { mutableStateOf(inactivityKick?.get("enabled")?.jsonPrimitive?.booleanOrNull ?: false) }
            val delayDays = remember(configJson.value) { mutableStateOf(inactivityKick?.get("delayDays")?.jsonPrimitive?.intOrNull?.toString() ?: "30") }
            val excludedRoles = remember(configJson.value) { mutableStateOf(inactivityKick?.get("excludedRoleIds")?.toString() ?: "[]") }

            Card(Modifier.fillMaxWidth()) {
              Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Inactivité", style = MaterialTheme.typography.titleMedium)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
                  Text("Activé", modifier = Modifier.weight(1f))
                  Switch(checked = enabled.value, onCheckedChange = { enabled.value = it })
                }
                OutlinedTextField(
                  value = delayDays.value,
                  onValueChange = { delayDays.value = it },
                  label = { Text("Délai (jours)") },
                  singleLine = true,
                  modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                  value = excludedRoles.value,
                  onValueChange = { excludedRoles.value = it },
                  label = { Text("excludedRoleIds (JSON array)") },
                  modifier = Modifier.fillMaxWidth()
                )
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                  Button(onClick = {
                    try {
                      val rolesEl = json.parseToJsonElement(excludedRoles.value)
                      val root = cfg?.toMutableMap() ?: mutableMapOf()
                      val akMap = (root["autokick"] as? JsonObject)?.toMutableMap() ?: mutableMapOf()
                      val kickMap = (akMap["inactivityKick"] as? JsonObject)?.toMutableMap() ?: mutableMapOf()
                      kickMap["enabled"] = JsonPrimitive(enabled.value)
                      kickMap["delayDays"] = JsonPrimitive(delayDays.value.toIntOrNull() ?: 30)
                      kickMap["excludedRoleIds"] = rolesEl
                      akMap["inactivityKick"] = JsonObject(kickMap)
                      root["autokick"] = JsonObject(akMap)
                      val newJson = Json { prettyPrint = true }.encodeToString(kotlinx.serialization.json.JsonObject.serializer(), JsonObject(root))
                      saveFullConfig(newJson)
                    } catch (e: Exception) {
                      scope.launch { snackbar.showSnackbar("Erreur: ${e.message}") }
                    }
                  }) { Text("Sauvegarder") }
                  Button(onClick = { refreshAll() }) { Text("Recharger") }
                }
              }
            }
          }

          3 -> {
            val cfg = currentConfigObject()
            val welcome = cfg?.get("welcome")?.jsonObject
            val wEnabled = remember(configJson.value) { mutableStateOf(welcome?.get("enabled")?.jsonPrimitive?.booleanOrNull ?: false) }
            val channelId = remember(configJson.value) { mutableStateOf(welcome?.get("channelId")?.jsonPrimitive?.contentOrNull ?: "") }
            val message = remember(configJson.value) { mutableStateOf(welcome?.get("message")?.jsonPrimitive?.contentOrNull ?: "") }

            Card(Modifier.fillMaxWidth()) {
              Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Welcome", style = MaterialTheme.typography.titleMedium)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
                  Text("Activé", modifier = Modifier.weight(1f))
                  Switch(checked = wEnabled.value, onCheckedChange = { wEnabled.value = it })
                }
                OutlinedTextField(
                  value = channelId.value,
                  onValueChange = { channelId.value = it },
                  label = { Text("Channel ID") },
                  singleLine = true,
                  modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                  value = message.value,
                  onValueChange = { message.value = it },
                  label = { Text("Message") },
                  modifier = Modifier.fillMaxWidth()
                )
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                  Button(onClick = {
                    val root = cfg?.toMutableMap() ?: mutableMapOf()
                    val welcomeMap = (root["welcome"] as? JsonObject)?.toMutableMap() ?: mutableMapOf()
                    welcomeMap["enabled"] = JsonPrimitive(wEnabled.value)
                    welcomeMap["channelId"] = JsonPrimitive(channelId.value)
                    welcomeMap["message"] = JsonPrimitive(message.value)
                    root["welcome"] = JsonObject(welcomeMap)
                    val newJson = Json { prettyPrint = true }.encodeToString(kotlinx.serialization.json.JsonObject.serializer(), JsonObject(root))
                    saveFullConfig(newJson)
                  }) { Text("Sauvegarder") }
                  Button(onClick = { refreshAll() }) { Text("Recharger") }
                }
              }
            }
          }

          else -> {
            Card(Modifier.fillMaxWidth()) {
              Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Configuration complète (éditeur JSON)", style = MaterialTheme.typography.titleMedium)
                Text(
                  "Éditeur universel: toutes les fonctionnalités du bot sont modifiables ici.",
                  style = MaterialTheme.typography.bodySmall
                )
                OutlinedTextField(
                  value = configEdit.value,
                  onValueChange = { configEdit.value = it },
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(320.dp),
                  label = { Text("Guild config JSON") },
                  textStyle = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace)
                )
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                  Button(onClick = { saveFullConfig(configEdit.value) }) { Text("Sauvegarder") }
                  Button(onClick = { configEdit.value = configJson.value ?: "" }) { Text("Annuler") }
                }
              }
            }
          }
        }
      }
    }
  }
}

