import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization.
  // After running `flutterfire configure`, uncomment the import and options:
  // import 'firebase_options.dart';
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: NmhasApp()));
}
