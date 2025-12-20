package com.bagbot.manager.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

@Composable
fun ConfigSection(
    title: String,
    icon: ImageVector,
    color: Color,
    onSave: suspend () -> Result<String>,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    var isSaving by remember { mutableStateOf(false) }
    var saveMessage by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()
    
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = color,
                    modifier = Modifier.size(28.dp)
                )
                Spacer(Modifier.width(12.dp))
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleLarge,
                    color = color
                )
            }
            
            Spacer(Modifier.height(16.dp))
            Divider(color = color.copy(alpha = 0.3f))
            Spacer(Modifier.height(16.dp))
            
            // Content
            content()
            
            Spacer(Modifier.height(16.dp))
            
            // Save button
            Button(
                onClick = {
                    scope.launch {
                        isSaving = true
                        saveMessage = null
                        val result = onSave()
                        result.fold(
                            onSuccess = { message ->
                                saveMessage = message
                            },
                            onFailure = { error ->
                                saveMessage = "❌ ${error.message}"
                            }
                        )
                        isSaving = false
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = color),
                enabled = !isSaving
            ) {
                if (isSaving) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(20.dp),
                        color = Color.White
                    )
                } else {
                    Icon(Icons.Default.Save, null)
                    Spacer(Modifier.width(8.dp))
                    Text("Sauvegarder")
                }
            }
            
            // Save message
            saveMessage?.let { message ->
                Spacer(Modifier.height(8.dp))
                Text(
                    text = message,
                    style = MaterialTheme.typography.bodySmall,
                    color = if (message.startsWith("❌")) {
                        MaterialTheme.colorScheme.error
                    } else {
                        Color(0xFF4CAF50)
                    }
                )
            }
        }
    }
}
