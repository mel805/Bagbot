package com.bagbot.manager.data.models

import com.google.gson.annotations.SerializedName

// Bot Stats
data class BotStats(
    val uptime: Long = 0,
    val guilds: Int = 0,
    val users: Int = 0,
    val commands: Int = 0,
    val memory: MemoryStats? = null
)

data class MemoryStats(
    val used: Long = 0,
    val total: Long = 0
)

// Discord User
data class DiscordUser(
    val id: String,
    val username: String,
    val discriminator: String = "0",
    val avatar: String? = null,
    @SerializedName("global_name") val globalName: String? = null
) {
    val displayName: String
        get() = globalName ?: username
    
    val tag: String
        get() = if (discriminator == "0") username else "$username#$discriminator"
}

// Guild
data class Guild(
    val id: String,
    val name: String,
    val icon: String? = null,
    @SerializedName("member_count") val memberCount: Int = 0,
    val owner: Boolean = false
)

// Commands
data class BotCommand(
    val name: String,
    val description: String,
    val category: String = "General",
    val usage: String? = null
)

// Music
data class MusicStatus(
    val playing: Boolean = false,
    val paused: Boolean = false,
    val track: Track? = null,
    val queue: List<Track> = emptyList(),
    val volume: Int = 100,
    val repeat: RepeatMode = RepeatMode.OFF,
    val position: Long = 0,
    val duration: Long = 0
)

data class Track(
    val title: String,
    val author: String,
    val url: String,
    val duration: Long = 0,
    val thumbnail: String? = null
)

enum class RepeatMode {
    OFF, TRACK, QUEUE
}

// Auth
data class AuthResponse(
    val success: Boolean,
    val token: String? = null,
    val user: DiscordUser? = null,
    val message: String? = null
)

data class OAuth UrlResponse(
    val url: String
)

// Health
data class HealthResponse(
    val status: String,
    val uptime: Long = 0,
    val timestamp: Long = 0,
    val bot: BotHealth? = null
)

data class BotHealth(
    val ready: Boolean = false,
    val guilds: Int = 0
)

// Generic Response
data class ApiResponse<T>(
    val success: Boolean,
    val data: T? = null,
    val error: String? = null
)
