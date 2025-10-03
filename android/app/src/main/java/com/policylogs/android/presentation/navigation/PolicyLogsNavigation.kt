package com.policylogs.android.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.policylogs.android.presentation.auth.AuthViewModel
import com.policylogs.android.presentation.auth.LoginScreen
import com.policylogs.android.presentation.auth.RegisterScreen
import com.policylogs.android.presentation.logs.LogsListScreen
import com.policylogs.android.presentation.logs.LogDetailScreen
import com.policylogs.android.presentation.profile.ProfileScreen

@Composable
fun PolicyLogsNavigation(
    navController: NavHostController = rememberNavController(),
    authViewModel: AuthViewModel = hiltViewModel()
) {
    val isLoggedIn by authViewModel.isLoggedIn.collectAsState()
    
    NavHost(
        navController = navController,
        startDestination = if (isLoggedIn) Screen.LogsList.route else Screen.Login.route
    ) {
        // Auth screens
        composable(Screen.Login.route) {
            LoginScreen(
                onNavigateToRegister = {
                    navController.navigate(Screen.Register.route)
                },
                onNavigateToLogs = {
                    navController.navigate(Screen.LogsList.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Screen.Register.route) {
            RegisterScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToLogs = {
                    navController.navigate(Screen.LogsList.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }
        
        // Main app screens
        composable(Screen.LogsList.route) {
            LogsListScreen(
                onNavigateToDetail = { logId ->
                    navController.navigate(Screen.LogDetail.createRoute(logId))
                },
                onNavigateToProfile = {
                    navController.navigate(Screen.Profile.route)
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Screen.LogDetail.route) { backStackEntry ->
            val logId = backStackEntry.arguments?.getString("logId")?.toIntOrNull() ?: 0
            LogDetailScreen(
                logId = logId,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable(Screen.Profile.route) {
            ProfileScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }
    }
}

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Register : Screen("register")
    object LogsList : Screen("logs_list")
    object LogDetail : Screen("log_detail/{logId}") {
        fun createRoute(logId: Int) = "log_detail/$logId"
    }
    object Profile : Screen("profile")
}