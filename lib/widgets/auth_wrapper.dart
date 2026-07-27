import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../main_screen.dart';
import '../views/login_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading screen while determining initial auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ),
          );
        }

        final user = snapshot.data;

        // User is not authenticated -> show LoginView
        if (user == null) {
          return const LoginView();
        }

        // Verify user role and active status in Firestore
        return FutureBuilder<void>(
          future: authService.verifyCustomerAuthorization(user.uid),
          builder: (context, authCheck) {
            if (authCheck.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0A0A0A),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                  ),
                ),
              );
            }

            if (authCheck.hasError) {
              // Customer authorization failed -> return LoginView (signOut has been executed)
              return const LoginView();
            }

            // User is authenticated, role == 'customer', and isActive == true -> show MainScreen
            return const MainScreen();
          },
        );
      },
    );
  }
}

