package com.policylogs.android.data.models

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class PolicyLog(
    val id: Int,
    val title: String,
    val description: String,
    @SerializedName("policy_document")
    val policyDocument: String?,
    @SerializedName("created_by_name")
    val createdByName: String,
    @SerializedName("created_at")
    val createdAt: Date,
    @SerializedName("updated_at")
    val updatedAt: Date,
    val status: String,
    val tags: List<Tag>,
    val comments: List<LogComment>,
    @SerializedName("comments_count")
    val commentsCount: Int
) : Parcelable

@Parcelize
data class Tag(
    val id: Int,
    val name: String,
    val color: String
) : Parcelable

@Parcelize
data class LogComment(
    val id: Int,
    val content: String,
    @SerializedName("author_name")
    val authorName: String,
    @SerializedName("created_at")
    val createdAt: Date
) : Parcelable

data class PolicyLogsResponse(
    val count: Int,
    val next: String?,
    val previous: String?,
    val results: List<PolicyLog>
)