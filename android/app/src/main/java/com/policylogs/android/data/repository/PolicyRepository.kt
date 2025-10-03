package com.policylogs.android.data.repository

import com.policylogs.android.data.models.*
import com.policylogs.android.data.network.AddCommentRequest
import com.policylogs.android.data.network.ApiService
import com.policylogs.android.data.network.CreateLogRequest
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PolicyRepository @Inject constructor(
    private val apiService: ApiService
) {
    
    suspend fun getPolicyLogs(page: Int = 1, search: String? = null): Result<PolicyLogsResponse> {
        return try {
            val response = apiService.getPolicyLogs(page, search)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun getPolicyLog(id: Int): Result<PolicyLog> {
        return try {
            val log = apiService.getPolicyLog(id)
            Result.success(log)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun createPolicyLog(
        title: String,
        description: String,
        status: String = "pending",
        tagIds: List<Int> = emptyList()
    ): Result<PolicyLog> {
        return try {
            val request = CreateLogRequest(title, description, status, tagIds)
            val log = apiService.createPolicyLog(request)
            Result.success(log)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun addComment(logId: Int, content: String): Result<LogComment> {
        return try {
            val request = AddCommentRequest(content)
            val comment = apiService.addComment(logId, request)
            Result.success(comment)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun getMyLogs(): Result<List<PolicyLog>> {
        return try {
            val response = apiService.getMyLogs()
            Result.success(response.results)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun getTags(): Result<List<Tag>> {
        return try {
            val tags = apiService.getTags()
            Result.success(tags)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}