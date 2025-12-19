package com.bagbot.manager.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

data class ConfigCategory(
    val id: String,
    val title: String,
    val icon: ImageVector,
    val color: Color,
    val description: String
)

@Composable
fun NewConfigHomeScreen(
    onCategoryClick: (String) -> Unit
) {
    val categories = listOf(
        ConfigCategory(
            "welcome",
            "Bienvenue",
            Icons.Default.EmojiPeople,
            Color(0xFF4CAF50),
            "Messages d'accueil"
        ),
        ConfigCategory(
            "goodbye",
            "Au revoir",
            Icons.Default.WavingHand,
            Color(0xFF8B4513),
            "Messages de départ"
        ),
        ConfigCategory(
            "logs",
            "Logs",
            Icons.Default.Description,
            Color(0xFF95A5A6),
            "Historique serveur"
        ),
        ConfigCategory(
            "tickets",
            "Tickets",
            Icons.Default.ConfirmationNumber,
            Color(0xFFE67E22),
            "Support utilisateurs"
        ),
        ConfigCategory(
            "confess",
            "Confessions",
            Icons.Default.Forum,
            Color(0xFFE91E63),
            "Confessions anonymes"
        ),
        ConfigCategory(
            "staff",
            "Staff",
            Icons.Default.Group,
            Color(0xFFFFD700),
            "Rôles équipe"
        ),
        ConfigCategory(
            "autokick",
            "AutoKick",
            Icons.Default.PersonRemove,
            Color(0xFFDC143C),
            "Kick automatique"
        ),
        ConfigCategory(
            "inactivity",
            "Inactivité",
            Icons.Default.Timer,
            Color(0xFFFF69B4),
            "Kick inactifs"
        ),
        ConfigCategory(
            "autothread",
            "AutoThread",
            Icons.Default.Forum,
            Color(0xFF20B2AA),
            "Threads auto"
        ),
        ConfigCategory(
            "disboard",
            "Disboard",
            Icons.Default.Campaign,
            Color(0xFF4169E1),
            "Rappels bump"
        ),
        ConfigCategory(
            "counting",
            "Comptage",
            Icons.Default.Calculate,
            Color(0xFF00D4FF),
            "Jeu de comptage"
        ),
        ConfigCategory(
            "truthdare",
            "Action/Vérité",
            Icons.Default.Casino,
            Color(0xFF9C27B0),
            "Jeu AouV"
        ),
        ConfigCategory(
            "economy",
            "Économie",
            Icons.Default.AttachMoney,
            Color(0xFF57F287),
            "Système monétaire"
        ),
        ConfigCategory(
            "levels",
            "Niveaux",
            Icons.Default.TrendingUp,
            Color(0xFFFEE75C),
            "Système XP"
        ),
        ConfigCategory(
            "boost",
            "Booster",
            Icons.Default.Rocket,
            Color(0xFFEB459E),
            "Bonus serveur"
        ),
        ConfigCategory(
            "geo",
            "Géo",
            Icons.Default.Map,
            Color(0xFF32CD32),
            "Localisation"
        ),
        ConfigCategory(
            "actions",
            "Actions",
            Icons.Default.Movie,
            Color(0xFFFF6B6B),
            "GIFs & Messages"
        )
    )
    
    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        contentPadding = PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(categories) { category ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(140.dp)
                    .clickable { onCategoryClick(category.id) },
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = category.color.copy(alpha = 0.15f)
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = category.icon,
                        contentDescription = null,
                        tint = category.color,
                        modifier = Modifier.size(48.dp)
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        text = category.title,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        textAlign = TextAlign.Center
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = category.description,
                        fontSize = 11.sp,
                        color = Color.Gray,
                        textAlign = TextAlign.Center,
                        maxLines = 2
                    )
                }
            }
        }
    }
}
