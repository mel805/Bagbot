package com.bagbot.manager.data.repository

import android.content.Context
import android.util.Log
import com.bagbot.manager.data.api.BotApiService
import com.bagbot.manager.data.models.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

class BotRepository(private val context: Context) {
    private var apiService: BotApiService? = null
    private var baseUrl: String? = null
    private var authToken: String? = null
    
    companion object {
        private const val TAG = "BotRepository"
        private const val PREFS_NAME = "bagbot_prefs"
        private const val KEY_BASE_URL = "base_url"
        private const val KEY_AUTH_TOKEN = "auth_token"
        private const val KEY_USER_ID = "user_id"
        private const val KEY_USERNAME = "username"
        private const val KEY_AVATAR = "avatar"
    }
    
    init {
        loadSettings()
    }
    
    private fun loadSettings() {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        baseUrl = prefs.getString(KEY_BASE_URL, null)
        authToken = prefs.getString(KEY_AUTH_TOKEN, null)
        
        if (baseUrl != null) {
            initializeApiService(baseUrl!!)
        }
    }
    
    fun initializeApiService(url: String) {
        baseUrl = url.trimEnd('/')
        
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        
        val client = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
        
        val retrofit = Retrofit.Builder()
            .baseUrl(baseUrl!!)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        
        apiService = retrofit.create(BotApiService::class.java)
        
        // Save URL
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_BASE_URL, baseUrl)
            .apply()
    }
    
    fun getBaseUrl(): String? = baseUrl
    
    fun isConfigured(): Boolean = apiService != null
    
    fun isAuthenticated(): Boolean = authToken != null
    
    fun setAuthToken(token: String) {
        authToken = token
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_AUTH_TOKEN, token)
            .apply()
    }
    
    fun clearAuth() {
        authToken = null
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .remove(KEY_AUTH_TOKEN)
            .remove(KEY_USER_ID)
            .remove(KEY_USERNAME)
            .remove(KEY_AVATAR)
            .apply()
    }
    
    fun getUserInfo(): DiscordUser? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val id = prefs.getString(KEY_USER_ID, null) ?: return null
        val username = prefs.getString(KEY_USERNAME, null) ?: return null
        val avatar = prefs.getString(KEY_AVATAR, null)
        
        return DiscordUser(
            id = id,
            username = username,
            avatar = avatar,
            discriminator = "0"
        )
    }
    
    private fun saveUserInfo(user: DiscordUser) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_USER_ID, user.id)
            .putString(KEY_USERNAME, user.username)
            .putString(KEY_AVATAR, user.avatar)
            .apply()
    }
    
    // Health Check
    suspend fun checkHealth(): Result<HealthResponse> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val response = service.getHealth()
            
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!)
            } else {
                Result.failure(Exception("Health check failed: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Health check error", e)
            Result.failure(e)
        }
    }
    
    // OAuth
    suspend fun getOAuthUrl(): Result<String> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val response = service.getOAuthUrl()
            
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.url)
            } else {
                Result.failure(Exception("Failed to get OAuth URL: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "OAuth URL error", e)
            Result.failure(e)
        }
    }
    
    suspend fun handleOAuthCallback(code: String): Result<DiscordUser> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val response = service.handleOAuthCallback(mapOf("code" to code))
            
            if (response.isSuccessful && response.body() != null) {
                val authResponse = response.body()!!
                if (authResponse.success && authResponse.token != null && authResponse.user != null) {
                    setAuthToken(authResponse.token)
                    saveUserInfo(authResponse.user)
                    Result.success(authResponse.user)
                } else {
                    Result.failure(Exception(authResponse.message ?: "Authentication failed"))
                }
            } else {
                Result.failure(Exception("OAuth callback failed: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "OAuth callback error", e)
            Result.failure(e)
        }
    }
    
    suspend fun logout(): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.logout("Bearer $token")
            clearAuth()
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.success(Unit) // Logout locally anyway
            }
        } catch (e: Exception) {
            Log.e(TAG, "Logout error", e)
            clearAuth() // Clear locally anyway
            Result.success(Unit)
        }
    }
    
    // Bot Stats
    suspend fun getBotStats(): Result<BotStats> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.getBotStats("Bearer $token")
            
            if (response.isSuccessful && response.body() != null) {
                val apiResponse = response.body()!!
                if (apiResponse.success && apiResponse.data != null) {
                    Result.success(apiResponse.data)
                } else {
                    Result.failure(Exception(apiResponse.error ?: "Failed to get stats"))
                }
            } else {
                Result.failure(Exception("Failed to get stats: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Bot stats error", e)
            Result.failure(e)
        }
    }
    
    // Guilds
    suspend fun getGuilds(): Result<List<Guild>> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.getGuilds("Bearer $token")
            
            if (response.isSuccessful && response.body() != null) {
                val apiResponse = response.body()!!
                if (apiResponse.success && apiResponse.data != null) {
                    Result.success(apiResponse.data)
                } else {
                    Result.failure(Exception(apiResponse.error ?: "Failed to get guilds"))
                }
            } else {
                Result.failure(Exception("Failed to get guilds: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Guilds error", e)
            Result.failure(e)
        }
    }
    
    // Commands
    suspend fun getCommands(): Result<List<BotCommand>> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.getCommands("Bearer $token")
            
            if (response.isSuccessful && response.body() != null) {
                val apiResponse = response.body()!!
                if (apiResponse.success && apiResponse.data != null) {
                    Result.success(apiResponse.data)
                } else {
                    Result.failure(Exception(apiResponse.error ?: "Failed to get commands"))
                }
            } else {
                Result.failure(Exception("Failed to get commands: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Commands error", e)
            Result.failure(e)
        }
    }
    
    // Music
    suspend fun getMusicStatus(guildId: String): Result<MusicStatus> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.getMusicStatus("Bearer $token", guildId)
            
            if (response.isSuccessful && response.body() != null) {
                val apiResponse = response.body()!!
                if (apiResponse.success && apiResponse.data != null) {
                    Result.success(apiResponse.data)
                } else {
                    Result.failure(Exception(apiResponse.error ?: "Failed to get music status"))
                }
            } else {
                Result.failure(Exception("Failed to get music status: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Music status error", e)
            Result.failure(e)
        }
    }
    
    suspend fun playMusic(guildId: String, query: String): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.playMusic("Bearer $token", guildId, mapOf("query" to query))
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to play music: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Play music error", e)
            Result.failure(e)
        }
    }
    
    suspend fun pauseMusic(guildId: String): Result<Unit> = musicAction(guildId, "pause") { service, token ->
        service.pauseMusic("Bearer $token", guildId)
    }
    
    suspend fun resumeMusic(guildId: String): Result<Unit> = musicAction(guildId, "resume") { service, token ->
        service.resumeMusic("Bearer $token", guildId)
    }
    
    suspend fun skipMusic(guildId: String): Result<Unit> = musicAction(guildId, "skip") { service, token ->
        service.skipMusic("Bearer $token", guildId)
    }
    
    suspend fun stopMusic(guildId: String): Result<Unit> = musicAction(guildId, "stop") { service, token ->
        service.stopMusic("Bearer $token", guildId)
    }
    
    suspend fun setVolume(guildId: String, volume: Int): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = service.setVolume("Bearer $token", guildId, mapOf("volume" to volume))
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to set volume: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Set volume error", e)
            Result.failure(e)
        }
    }
    
    private suspend fun musicAction(
        guildId: String,
        action: String,
        apiCall: suspend (BotApiService, String) -> retrofit2.Response<ApiResponse<Unit>>
    ): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val response = apiCall(service, token)
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to $action music: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "$action music error", e)
            Result.failure(e)
        }
    }
    
    // Moderation
    suspend fun banUser(guildId: String, userId: String, reason: String?): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val data = mutableMapOf("userId" to userId)
            if (reason != null) data["reason"] = reason
            
            val response = service.banUser("Bearer $token", guildId, data)
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to ban user: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Ban user error", e)
            Result.failure(e)
        }
    }
    
    suspend fun kickUser(guildId: String, userId: String, reason: String?): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val data = mutableMapOf("userId" to userId)
            if (reason != null) data["reason"] = reason
            
            val response = service.kickUser("Bearer $token", guildId, data)
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to kick user: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Kick user error", e)
            Result.failure(e)
        }
    }
    
    suspend fun timeoutUser(guildId: String, userId: String, duration: Long, reason: String?): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val service = apiService ?: throw IllegalStateException("API not configured")
            val token = authToken ?: throw IllegalStateException("Not authenticated")
            
            val data = mutableMapOf<String, Any>(
                "userId" to userId,
                "duration" to duration
            )
            if (reason != null) data["reason"] = reason
            
            val response = service.timeoutUser("Bearer $token", guildId, data)
            
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to timeout user: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Timeout user error", e)
            Result.failure(e)
        }
    }
}
