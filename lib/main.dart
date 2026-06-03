import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lune/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'routes/app_router.dart';
import 'data/services/local/audio_background_service.dart';
import 'data/services/local/storage_service.dart';


final storageService = StorageService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  await Firebase.initializeApp();
  await initializeService();

  await storageService.init();

  //await storageService.seedDemoData();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Lune',
      theme: AppTheme.darkTheme,
    );
  }
}