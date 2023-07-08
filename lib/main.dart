import 'package:arabeia_website/db/db.dart';
import 'package:arabeia_website/ui/app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      child: EasyLocalization(
          supportedLocales: const [Locale('ar')],
          path: 'assets/translations/',
          fallbackLocale: const Locale('ar'),
          child: const App()
      ),
    ),
  );
}
