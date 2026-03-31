import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file for OpenRouter API keys
  await dotenv.load(fileName: '.env');

  // Initialize Firebase Ecosystem (using the newly generated configuration)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VicharaneApp());
}
