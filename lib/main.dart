import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oinvnrtqwerxxzextqhi.supabase.co',
    anonKey: 'sb_publishable_oWIdTWsd58zuRZdowA-H-g_Gkshd8sc',
  );

  runApp(const VocabGameApp());
}

class VocabGameApp extends StatelessWidget {
  const VocabGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '6 Sefer Kelime Oyunu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginScreen(),

    );
  }
}
