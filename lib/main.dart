import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050A14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4FF),
          secondary: Color(0xFF0066FF),
          surface: Color(0xFF0D1B2A),
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
