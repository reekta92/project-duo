import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Projenin asenkron olarak başlaması için main fonksiyonunu Future yapıyoruz.
Future<void> main() async {
  // Flutter motorunun tam olarak başlatıldığından emin oluyoruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase veritabanı bağlantımızı kuruyoruz.
  // DİKKAT: Buradaki URL ve Key değerlerini kendi Supabase panelinizden alıp değiştirmelisiniz.
  await Supabase.initialize(
    url: 'https://oinvnrtqwerxxzextqhi.supabase.co',
    anonKey: 'sb_publishable_oWIdTWsd58zuRZdowA-H-g_Gkshd8sc',
  );

  runApp(const VocabGameApp());
}

// Uygulamamızın ana kök widget'ı
class VocabGameApp extends StatelessWidget {
  const VocabGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '6 Sefer Kelime Oyunu',
      debugShowCheckedModeBanner: false, // Sağ üstteki "DEBUG" yazısını kaldırır
      theme: ThemeData(
        // Oyununuza uygun temel bir renk teması (Mavi tonları)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Uygulama açıldığında ilk olarak Giriş Ekranı (LoginScreen) gösterilecek
      home: const LoginScreen(), 
    );
  }
}

// Story-1: Kullanıcı Giriş Ekranı İskeleti
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Supabase istemcisini çağırıyoruz
  final supabase = Supabase.instance.client;

  // Kullanıcının yazdığı verileri tutacak kontrolcüler
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false; // Yükleniyor animasyonu için

  // --- KAYIT OLMA FONKSİYONU ---
  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı! Şimdi giriş yapabilirsiniz.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt Hatası: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- GİRİŞ YAPMA FONKSİYONU ---
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş Başarılı!')),
      );
      // Başarılı girişten sonra uygulamanın ana sayfasına yönlendirme kodu buraya gelecek
      // Navigator.pushReplacement(...)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap / Kayıt Ol')),
      body: Center(
        child: SingleChildScrollView( // Klavye açıldığında ekranın kayabilmesi için
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 40),
              
              // E-POSTA ALANI
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // ŞİFRE ALANI
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true, // Şifreyi gizler
              ),
              const SizedBox(height: 24),

              // GİRİŞ YAP VE KAYIT OL BUTONLARI
              _isLoading 
                ? const CircularProgressIndicator() // Yükleniyorsa dönen ikon göster
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Giriş Yap'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _signUp,
                        child: const Text('Hesabın yok mu? Yeni Kayıt Ol'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
