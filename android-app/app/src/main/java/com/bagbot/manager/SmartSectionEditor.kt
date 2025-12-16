package com.bagbot.manager

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull

private fun looksLikeSnowflake(s: String): Boolean = s.length in 15..22 && s.all { it.isDigit() }

private fun JsonElement.asObjectOrEmpty(): JsonObject = (this as? JsonObject) ?: JsonObject(emptyMap())
private fun JsonElement.asArrayOrEmpty(): JsonArray = (this as? JsonArray) ?: JsonArray(emptyList())

@Composable
fun SmartSectionEditor(
  title: String,
  sectionKey: String,
  section: JsonObject,
  channels: Map<String, String>,
  roles: Map<String, String>,
  members: Map<String, String>,
  rawJson: String,
  onRawJsonChange: (String) -> Unit,
  onSaveSection: (JsonObject) -> Unit,
  onBack: () -> Unit,
) {
  // Use a local Json instance for parsing raw JSON
  val json = remember { Json { ignoreUnknownKeys = true } }
  val advanced = remember { mutableStateOf(false) }

  // Keep a shallow editable map for primitive fields only
  val editableKeys = section.entries
    .filter { (k, v) ->
      // avoid huge maps
      k !in setOf("balances", "records", "pendingJoiners", "locations", "users", "inactivityTracking") &&
        (v is JsonPrimitive || v is JsonArray)
    }
    .map { it.key }
    .sorted()

  Column(
    modifier = Modifier
      .padding(16.dp)
      .verticalScroll(rememberScrollState()),
    verticalArrangement = Arrangement.spacedBy(12.dp)
  ) {
    Text(title, style = MaterialTheme.typography.titleLarge)

    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
      Text("Mode avancé JSON", modifier = Modifier.weight(1f))
      Switch(checked = advanced.value, onCheckedChange = { advanced.value = it })
    }

    if (advanced.value) {
      Card(Modifier.fillMaxWidth()) {
        Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
          Text("JSON (${sectionKey})", style = MaterialTheme.typography.titleMedium)
          OutlinedTextField(
            value = rawJson,
            onValueChange = { onRawJsonChange(it) },
            modifier = Modifier.fillMaxWidth(),
            textStyle = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace),
            minLines = 12,
            label = { Text("JSON") }
          )
        }
      }
      Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        Button(onClick = {
          // parent already validates via JsonUtil, keep simple
          try {
            val parsed = json.parseToJsonElement(rawJson).asObjectOrEmpty()
            onSaveSection(parsed)
          } catch (_: Exception) {
            // ignore here; parent shows error on save
          }
        }) { Text("Sauvegarder") }
        OutlinedButton(onClick = onBack) { Text("Retour") }
      }
      return
    }

    if (editableKeys.isEmpty()) {
      Text("Aucun champ simple détecté. Passe en mode JSON.", style = MaterialTheme.typography.bodySmall)
      OutlinedButton(onClick = { advanced.value = true }) { Text("Ouvrir JSON") }
      OutlinedButton(onClick = onBack) { Text("Retour") }
      return
    }

    val working = remember(section) { mutableStateOf(section.toMutableMap()) }

    editableKeys.forEach { k ->
      val v = working.value[k]
      when (v) {
        is JsonPrimitive -> {
          val bool = v.booleanOrNull
          if (bool != null) {
            Card(Modifier.fillMaxWidth()) {
              Row(
                modifier = Modifier.padding(14.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
              ) {
                Text(k, modifier = Modifier.weight(1f))
                Switch(
                  checked = bool,
                  onCheckedChange = { checked -> working.value[k] = JsonPrimitive(checked) }
                )
              }
            }
          } else {
            val s = v.content
            val isId = looksLikeSnowflake(s) && (k.contains("id", ignoreCase = true) || k.endsWith("Id"))
            val picker = when {
              isId && k.contains("channel", ignoreCase = true) -> channels
              isId && k.contains("role", ignoreCase = true) -> roles
              isId && k.contains("user", ignoreCase = true) -> members
              else -> emptyMap()
            }
            if (picker.isNotEmpty()) {
              IdPickerField(
                label = k,
                selectedId = s,
                items = picker,
                onChange = { nid -> working.value[k] = JsonPrimitive(nid) }
              )
            } else {
              OutlinedTextField(
                value = s,
                onValueChange = { nv -> working.value[k] = JsonPrimitive(nv) },
                label = { Text(k) },
                modifier = Modifier.fillMaxWidth()
              )
            }
          }
        }
        is JsonArray -> {
          val arr = v.asArrayOrEmpty()
          val ids = arr.mapNotNull { (it as? JsonPrimitive)?.content }
          val allSnowflakes = ids.isNotEmpty() && ids.all { looksLikeSnowflake(it) }
          val picker = when {
            allSnowflakes && k.contains("channel", ignoreCase = true) -> channels
            allSnowflakes && k.contains("role", ignoreCase = true) -> roles
            allSnowflakes && k.contains("user", ignoreCase = true) -> members
            else -> emptyMap()
          }
          if (picker.isNotEmpty()) {
            MultiIdPickerField(
              label = k,
              selectedIds = ids,
              items = picker,
              onChange = { newIds ->
                working.value[k] = JsonArray(newIds.map { JsonPrimitive(it) })
              }
            )
          } else {
            OutlinedTextField(
              value = ids.joinToString(","),
              onValueChange = { nv ->
                val list = nv.split(",").map { it.trim() }.filter { it.isNotBlank() }
                working.value[k] = JsonArray(list.map { JsonPrimitive(it) })
              },
              label = { Text("$k (liste)") },
              modifier = Modifier.fillMaxWidth(),
              textStyle = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace)
            )
          }
        }
      }
    }

    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
      Button(onClick = {
        val out = JsonObject(working.value.toMap())
        onSaveSection(out)
      }) { Text("Sauvegarder") }
      OutlinedButton(onClick = onBack) { Text("Retour") }
      OutlinedButton(onClick = { advanced.value = true }) { Text("JSON") }
    }
  }
}

