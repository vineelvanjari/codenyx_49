import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  runApp(const VicharaneApp());
}
