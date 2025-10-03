package com.policylogs.android.data.models

import com.google.gson.annotations.SerializedName
import java.util.Date

data class User(
    val id: Int,
    val username: String,
    val email: String?,
    @SerializedName("first_name")
    val firstName: String?,
    @SerializedName("last_name")
    val lastName: String?,
    @SerializedName("date_joined")
    val dateJoined: Date
)

data class UserProfile(
    val user: User,
    val avatar: String?,
    val bio: String?,
    @SerializedName("phone_number")
    val phoneNumber: String?,
    val department: String?
)

data class LoginRequest(
    val username: String,
    val password: String
)

data class LoginResponse(
    val token: String,
    val user: User
)

data class RegisterRequest(
    val username: String,
    val email: String,
    @SerializedName("first_name")
    val firstName: String,
    @SerializedName("last_name")
    val lastName: String,
    val password: String,
    @SerializedName("password_confirm")
    val passwordConfirm: String
)