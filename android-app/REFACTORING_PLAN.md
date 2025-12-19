# 🔧 Plan de refactoring complet de l'application Android v2.3

## 📋 Liste complète des sections du Dashboard

### ✅ Sections actuellement dans l'app (partiel)
1. ✅ Dashboard
2. ✅ Admin (gestion accès)
3. ✅ Configuration (avec groupes)

### ❌ Sections manquantes ou incomplètes

| # | Section | ID | Description | Priorité |
|---|---------|----|-----------|---------| 
| 1 | 💰 Économie | `eco` | Gestion complète des balances | 🔴 Haute |
| 2 | 📈 Niveaux | `niv` | Gestion XP et niveaux | 🔴 Haute |
| 3 | 🚀 Booster | `boost` | Système de boost serveur | 🟡 Moyenne |
| 4 | 🔢 Comptage | `count` | Configuration comptage | 🔴 Haute |
| 5 | 🎲 A/V | `av` | Action ou Vérité | 🟡 Moyenne |
| 6 | 🎬 Actions | `actions` | GIFs et actions | 🟢 Basse |
| 7 | 📝 Logs | `logs` | Configuration des logs | 🔴 Haute |
| 8 | 🎫 Tickets | `tick` | Système de tickets | 🔴 Haute |
| 9 | 💬 Confess | `conf` | Confessions anonymes | 🟡 Moyenne |
| 10 | 👋 Welcome | `welcome` | Messages de bienvenue | 🔴 Haute |
| 11 | 😢 Goodbye | `goodbye` | Messages d'au revoir | 🔴 Haute |
| 12 | 👥 Staff | `staff` | Rôles staff | 🔴 Haute |
| 13 | 👢 AutoKick | `autokick` | Kick automatique | 🟡 Moyenne |
| 14 | ⏰ Inactivité | `inactivity` | Gestion inactivité | 🟡 Moyenne |
| 15 | 🧵 AutoThread | `autothread` | Création auto de threads | 🟡 Moyenne |
| 16 | 📢 Disboard | `disboard` | Rappels Disboard | 🟡 Moyenne |
| 17 | 🌍 Géo | `geo` | Géolocalisation | 🔴 Haute |
| 18 | 💾 Backups | `bak` | Sauvegardes | 🟢 Basse |
| 19 | 🎮 Contrôle | `ctrl` | Contrôles bot | 🟢 Basse |

---

## 🎯 Objectifs de la refonte

### 1. Interface utilisateur complète
- ❌ **Supprimer** les champs JSON bruts
- ✅ **Créer** des formulaires visuels pour chaque section
- ✅ **Utiliser** les composants existants (MemberSelector, ChannelSelector, RoleSelector)

### 2. Sections éditables
Chaque section doit avoir :
- ✅ Switch ON/OFF pour activer/désactiver
- ✅ Champs de texte pour les messages
- ✅ Sélecteurs pour membres/channels/rôles
- ✅ Boutons de sauvegarde par section
- ✅ Feedback visuel (loading, succès, erreur)

### 3. Composants réutilisables à créer

```kotlin
// Composant switch avec label
@Composable
fun ConfigSwitch(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
)

// Composant champ de texte
@Composable
fun ConfigTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String = "",
    multiline: Boolean = false
)

// Composant champ numérique
@Composable
fun ConfigNumberField(
    label: String,
    value: Int,
    onValueChange: (Int) -> Unit,
    min: Int? = null,
    max: Int? = null
)

// Composant section avec sauvegarde
@Composable
fun ConfigSection(
    title: String,
    icon: ImageVector,
    color: Color,
    onSave: suspend () -> Result<Unit>,
    content: @Composable () -> Unit
)
```

---

## 🏗️ Architecture proposée

### Nouvelle structure de fichiers

```
android-app/app/src/main/java/com/bagbot/manager/
├── ui/
│   ├── components/
│   │   ├── MemberSelector.kt (existe)
│   │   ├── ChannelSelector.kt (existe)
│   │   ├── RoleSelector.kt (existe)
│   │   ├── ConfigSwitch.kt (nouveau)
│   │   ├── ConfigTextField.kt (nouveau)
│   │   ├── ConfigNumberField.kt (nouveau)
│   │   └── ConfigSection.kt (nouveau)
│   ├── screens/
│   │   ├── DashboardScreen.kt (existe)
│   │   ├── AdminScreen.kt (existe)
│   │   └── config/
│   │       ├── EconomyConfigScreen.kt (nouveau)
│   │       ├── LevelsConfigScreen.kt (nouveau)
│   │       ├── TicketsConfigScreen.kt (nouveau)
│   │       ├── WelcomeConfigScreen.kt (nouveau)
│   │       ├── GoodbyeConfigScreen.kt (nouveau)
│   │       ├── LogsConfigScreen.kt (nouveau)
│   │       ├── CountingConfigScreen.kt (nouveau)
│   │       ├── ConfessConfigScreen.kt (nouveau)
│   │       ├── StaffConfigScreen.kt (nouveau)
│   │       ├── AutoKickConfigScreen.kt (nouveau)
│   │       ├── InactivityConfigScreen.kt (nouveau)
│   │       ├── AutoThreadConfigScreen.kt (nouveau)
│   │       ├── DisboardConfigScreen.kt (nouveau)
│   │       ├── GeoConfigScreen.kt (nouveau)
│   │       └── TruthDareConfigScreen.kt (nouveau)
│   └── theme/ (existe)
├── data/
│   └── models/
│       ├── EconomyConfig.kt (nouveau)
│       ├── LevelsConfig.kt (nouveau)
│       ├── TicketsConfig.kt (nouveau)
│       └── ... (autres modèles)
├── ApiClient.kt (existe)
├── SettingsStore.kt (existe)
└── MainActivity.kt (existe)
```

---

## 📝 Plan d'implémentation

### Phase 1: Composants réutilisables (2-3h)
1. Créer `ConfigSwitch.kt`
2. Créer `ConfigTextField.kt`
3. Créer `ConfigNumberField.kt`
4. Créer `ConfigSection.kt` avec gestion de sauvegarde

### Phase 2: Modèles de données (1-2h)
1. Créer les data classes pour chaque configuration
2. Ajouter la sérialisation JSON

### Phase 3: Screens de configuration (6-8h)
Pour chaque section prioritaire :
1. ✅ Economy
2. ✅ Levels
3. ✅ Tickets
4. ✅ Welcome/Goodbye
5. ✅ Logs
6. ✅ Counting
7. ✅ Confess
8. ✅ Staff
9. ✅ Geo

### Phase 4: Navigation et intégration (1-2h)
1. Mettre à jour la navigation
2. Intégrer toutes les sections
3. Tests end-to-end

### Phase 5: Sections secondaires (3-4h)
1. AutoKick
2. Inactivity
3. AutoThread
4. Disboard
5. TruthDare
6. Booster
7. Actions
8. Backups
9. Contrôle

---

## 🎨 Exemple de formulaire éditable

### AVANT (JSON brut - à supprimer)
```kotlin
OutlinedTextField(
    value = jsonText,
    onValueChange = { jsonText = it },
    modifier = Modifier.fillMaxWidth().heightIn(min = 150.dp),
    textStyle = MaterialTheme.typography.bodySmall.copy(
        fontFamily = FontFamily.Monospace
    )
)
```

### APRÈS (Formulaire visuel)
```kotlin
ConfigSection(
    title = "👋 Messages de bienvenue",
    icon = Icons.Default.EmojiPeople,
    color = Color(0xFF4CAF50),
    onSave = { saveWelcomeConfig() }
) {
    ConfigSwitch(
        label = "Activer les messages de bienvenue",
        checked = welcomeEnabled,
        onCheckedChange = { welcomeEnabled = it }
    )
    
    Spacer(Modifier.height(16.dp))
    
    ChannelSelector(
        channels = channels,
        selectedChannelId = welcomeChannel,
        onChannelSelected = { welcomeChannel = it },
        label = "Salon de bienvenue"
    )
    
    Spacer(Modifier.height(16.dp))
    
    ConfigTextField(
        label = "Message de bienvenue",
        value = welcomeMessage,
        onValueChange = { welcomeMessage = it },
        placeholder = "Bienvenue {user} sur le serveur !",
        multiline = true
    )
}
```

---

## 🌍 Géolocalisation - Fix requis

### Problème actuel
- La section Géo n'est pas visible dans l'app
- Le composant `GeoMapViewer` existe mais n'est pas affiché

### Solution
1. Créer un écran dédié `GeoConfigScreen.kt`
2. Afficher la liste des localisations
3. Ajouter une WebView ou un lien vers OpenStreetMap
4. Permettre l'ajout/suppression de localisations

---

## 📊 Estimation totale

| Phase | Temps estimé | Complexité |
|-------|-------------|-----------|
| Composants réutilisables | 2-3h | 🟢 Faible |
| Modèles de données | 1-2h | 🟢 Faible |
| Screens prioritaires | 6-8h | 🟡 Moyenne |
| Navigation | 1-2h | 🟢 Faible |
| Sections secondaires | 3-4h | 🟡 Moyenne |
| Tests et debug | 2-3h | 🟡 Moyenne |
| **TOTAL** | **15-22h** | 🔴 **Élevée** |

---

## ⚠️ Avertissement

Cette refonte est **MASSIVE** et nécessitera :
- Création de 15+ nouveaux fichiers Kotlin
- Modification complète de l'architecture
- Tests approfondis de chaque section
- Plusieurs cycles de compilation/debug

### Approche recommandée
1. **Itérative** : Implémenter section par section
2. **Testée** : Compiler et tester après chaque section
3. **Documentée** : Garder une trace des modifications

---

## 🚀 Prochaines étapes immédiates

1. ✅ Créer les composants réutilisables
2. ✅ Implémenter les 3 sections les plus importantes (Economy, Levels, Tickets)
3. ✅ Tester et valider l'approche
4. ✅ Continuer avec les autres sections
5. ✅ Compiler et publier la version finale

---

**Date de création** : 19 décembre 2025  
**Version cible** : 2.4.0 ou 3.0.0  
**Complexité** : 🔴 Très élevée
