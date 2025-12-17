package com.bagbot.manager.data.api

import com.bagbot.manager.data.models.*
import retrofit2.Response
import retrofit2.http.*

interface BotApiService {
    // Health
    @GET("/health")
    suspend fun getHealth(): Response<HealthResponse>
    
    // Auth
    @GET("/auth/discord/url")
    suspend fun getOAuthUrl(): Response<OAuthUrlResponse>
    
    @POST("/auth/discord/callback")
    suspend fun handleOAuthCallback(@Body code: Map<String, String>): Response<AuthResponse>
    
    @POST("/auth/logout")
    suspend fun logout(@Header("Authorization") token: String): Response<ApiResponse<Unit>>
    
    // Bot Stats
    @GET("/bot/stats")
    suspend fun getBotStats(@Header("Authorization") token: String): Response<ApiResponse<BotStats>>
    
    // User Info
    @GET("/bot/user")
    suspend fun getUserInfo(@Header("Authorization") token: String): Response<ApiResponse<DiscordUser>>
    
    // Guilds
    @GET("/bot/guilds")
    suspend fun getGuilds(@Header("Authorization") token: String): Response<ApiResponse<List<Guild>>>
    
    // Commands
    @GET("/bot/commands")
    suspend fun getCommands(@Header("Authorization") token: String): Response<ApiResponse<List<BotCommand>>>
    
    // Music
    @GET("/bot/music/{guildId}/status")
    suspend fun getMusicStatus(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String
    ): Response<ApiResponse<MusicStatus>>
    
    @POST("/bot/music/{guildId}/play")
    suspend fun playMusic(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String,
        @Body query: Map<String, String>
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/music/{guildId}/pause")
    suspend fun pauseMusic(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/music/{guildId}/resume")
    suspend fun resumeMusic(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/music/{guildId}/skip")
    suspend fun skipMusic(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/music/{guildId}/stop")
    suspend fun stopMusic(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/music/{guildId}/volume")
    suspend fun setVolume(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String,
        @Body volume: Map<String, Int>
    ): Response<ApiResponse<Unit>>
    
    // Moderation
    @POST("/bot/moderation/{guildId}/ban")
    suspend fun banUser(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String,
        @Body data: Map<String, String>
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/moderation/{guildId}/kick")
    suspend fun kickUser(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String,
        @Body data: Map<String, String>
    ): Response<ApiResponse<Unit>>
    
    @POST("/bot/moderation/{guildId}/timeout")
    suspend fun timeoutUser(
        @Header("Authorization") token: String,
        @Path("guildId") guildId: String,
        @Body data: Map<String, Any>
    ): Response<ApiResponse<Unit>>
}
