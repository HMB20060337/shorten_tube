import 'package:ai_youtube/features/main/screens/homepage.dart';
import 'package:ai_youtube/features/main/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grock/grock.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('apiKey');
  await Hive.openBox('db');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: Grock.navigationKey, // added line
          scaffoldMessengerKey: Grock.scaffoldMessengerKey,
          home: Hive.box('apiKey').containsKey('apiKey')
              ? const HomePage()
              : const Welcome()); }
    );
  }
}
