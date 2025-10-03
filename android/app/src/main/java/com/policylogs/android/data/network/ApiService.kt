package com.policylogs.android.data.network

import com.policylogs.android.data.models.*
import retrofit2.http.*

interface ApiService {
    
    // Authentication endpoints
    @POST("auth/login/")
    suspend fun login(@Body request: LoginRequest): LoginResponse
    
    @POST("auth/register/")
    suspend fun register(@Body request: RegisterRequest): User
    
    @POST("auth/logout/")
    suspend fun logout()
    
    @GET("auth/profile/")
    suspend fun getProfile(): UserProfile
    
    // Policy logs endpoints
    @GET("policy-logs/")
    suspend fun getPolicyLogs(
        @Query("page") page: Int = 1,
        @Query("search") search: String? = null
    ): PolicyLogsResponse
    
    @GET("policy-logs/{id}/")
    suspend fun getPolicyLog(@Path("id") id: Int): PolicyLog
    
    @POST("policy-logs/")
    suspend fun createPolicyLog(@Body request: CreateLogRequest): PolicyLog
    
    @POST("policy-logs/{id}/add_comment/")
    suspend fun addComment(
        @Path("id") logId: Int,
        @Body request: AddCommentRequest
    ): LogComment
    
    @GET("policy-logs/my_logs/")
    suspend fun getMyLogs(): PolicyLogsResponse
    
    // Tags endpoints
    @GET("tags/")
    suspend fun getTags(): List<Tag>
}

data class CreateLogRequest(
    val title: String,
    val description: String,
    val status: String = "pending",
    @SerializedName("tag_ids")
    val tagIds: List<Int> = emptyList()
)

data class AddCommentRequest(
    val content: String
)