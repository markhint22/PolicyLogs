package com.policylogs.android.data.repository

import com.policylogs.android.data.local.UserPreferences
import com.policylogs.android.data.models.*
import com.policylogs.android.data.network.ApiService
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val apiService: ApiService,
    private val userPreferences: UserPreferences
) {
    
    fun getAuthToken(): Flow<String?> = userPreferences.authToken
    
    fun getCurrentUser(): Flow<User?> = userPreferences.currentUser
    
    suspend fun login(username: String, password: String): Result<LoginResponse> {
        return try {
            val response = apiService.login(LoginRequest(username, password))
            userPreferences.saveAuthToken(response.token)
            userPreferences.saveUser(response.user)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun register(
        username: String,
        email: String,
        firstName: String,
        lastName: String,
        password: String
    ): Result<User> {
        return try {
            val request = RegisterRequest(
                username = username,
                email = email,
                firstName = firstName,
                lastName = lastName,
                password = password,
                passwordConfirm = password
            )
            val user = apiService.register(request)
            Result.success(user)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun logout(): Result<Unit> {
        return try {
            apiService.logout()
            userPreferences.clearAuthData()
            Result.success(Unit)
        } catch (e: Exception) {
            // Even if API call fails, clear local data
            userPreferences.clearAuthData()
            Result.success(Unit)
        }
    }
    
    suspend fun getProfile(): Result<UserProfile> {
        return try {
            val profile = apiService.getProfile()
            userPreferences.saveUser(profile.user)
            Result.success(profile)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun isLoggedIn(): Boolean {
        val token = userPreferences.getAuthTokenSync()
        val user = userPreferences.getCurrentUserSync()
        return !token.isNullOrEmpty() && user != null
    }
}