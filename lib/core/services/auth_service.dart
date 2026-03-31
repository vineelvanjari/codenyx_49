import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '406908570322-skuqfncsr6bjg3e8fmv0ptjl78dgn0qi.apps.googleusercontent.com',
  );
  final FirestoreService _firestoreService = FirestoreService();

  // Stream listening to auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Native Web OAuth bypasses the strict origins using the built-in Firebase proxy
        final provider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithPopup(provider);
        
        if (userCredential.user != null) {
          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? 'Unknown',
          );
          await _firestoreService.createUser(userModel);
        }
        return userCredential;
      } else {
        // Android / iOS Original Flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // The user canceled the sign-in

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? 'Unknown',
          );
          await _firestoreService.createUser(userModel);
        }
        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
