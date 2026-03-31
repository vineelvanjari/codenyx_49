import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/user_model.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import '../startup/startup_dashboard.dart';
import '../investor/investor_feed.dart';
import '../developer/gig_board.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        // Show loading while checking connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is NOT logged in, show Login Screen
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // If user IS logged in, fetch their Role from Firestore
        return FutureBuilder<UserModel?>(
          future: FirestoreService().getUser(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userModel = userSnapshot.data;
            
            // If they haven't selected a role, show Role Selection
            if (userModel == null || userModel.role == null || userModel.role!.isEmpty) {
              return RoleSelectionScreen(user: user);
            }

            // Route to correct Dashboard
            switch (userModel.role) {
              case 'startup':
                return const StartupDashboard();
              case 'investor':
                return const InvestorFeed();
              case 'developer':
                return const GigBoard();
              default:
                return RoleSelectionScreen(user: user);
            }
          },
        );
      },
    );
  }
}
