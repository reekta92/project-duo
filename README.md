# Project Duo - Kelime Ezberleme ve Öğrenme Uygulaması 🚀

**Yazılım Yapımı Dersi Dönem Projesi**
"6 Sefer Tekrar Prensibi" temel alınarak geliştirilmiş, kalıcı öğrenmeyi hedefleyen modern bir İngilizce-Türkçe kelime ezberleme ve oyun uygulamasıdır.

## 🌟 Özellikler

- **6 Sefer Tekrar Prensibi (Spaced Repetition):** Kelimelerin kalıcı hafızaya aktarılmasını sağlayan bilimsel öğrenme algoritması (1 gün, 1 hafta, 1 ay, 3 ay, 6 ay ve 1 yıl aralıklarla tekrar).
- **Modern "Zen" Arayüz:** Tam ekran bulanık (glassmorphism) arka planlar, yumuşak geçişler ve özel animasyonlar ile mobil odaklı kusursuz kullanıcı deneyimi.
- **Oyunlaştırma (Gamification):**
  - **Quiz Modu:** Günlük tekrarlarınızı yapabileceğiniz çoktan seçmeli testler.
  - **Wordle:** Öğrendiğiniz kelimeleri tahmin etmeye çalıştığınız popüler Wordle oyununun uygulamaya entegre hali.
  - **Kelime Zinciri (Word Chain):** Son harfle yeni kelime türetme oyunu.
- **İlerleme Takibi:** Detaylı istatistik ekranı ile başarı oranınızı, öğrendiğiniz ve ustalaştığınız kelimeleri takip edin. PDF olarak rapor alın.
- **Kişiselleştirilebilir Kelime Havuzu:** Kendi kelimelerinizi ekleyin, düzenleyin ve LLM destekli örnek cümlelerle öğrenmeyi pekiştirin.

## 🛠️ Kullanılan Teknolojiler

- **Frontend:** Flutter & Dart
- **Backend/Veritabanı:** Supabase (PostgreSQL, Authentication)
- **Tasarım Dili:** Özel tasarım Glassmorphism "Zen" Component Kütüphanesi

## 📱 Ekran Görüntüleri ve Arayüz Bileşenleri
Tüm uygulama, görsel bütünlüğü sağlamak amacıyla baştan sona `GlassCard`, `ZenButton`, ve `ZenTextField` gibi özel bileşenlerle güncellenmiştir. Akıcı sayfa geçişleri `ZenAnimations.staggeredEntrance` ile sağlanmaktadır.

## 🚀 Kurulum

1. **Gereksinimler:**
   - [Flutter SDK](https://docs.flutter.dev/get-started/install) (Sürüm 3.x)
   - Android Studio / Android SDK (Android APK oluşturmak için)
   - Java 17 veya Java 21 (Gradle uyumluluğu için gereklidir - **Java 26 desteklenmez!**)
   - Supabase hesabı ve projesi

2. **Projeyi Klonlayın:**
   ```bash
   git clone https://github.com/reekta92/project-duo.git
   cd project-duo
   ```

3. **Çevresel Değişkenleri Ayarlayın:**
   Proje kök dizininde bulunan `.env.example` dosyasını kopyalayıp `.env` adında yeni bir dosya oluşturun ve Supabase bilgilerinizi girin:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```

5. **Uygulamayı Çalıştırın:**
   ```bash
   flutter run
   ```

## 📦 APK Oluşturma (Release Build)

Android için optimize edilmiş bir APK oluşturmak isterseniz:

```bash
flutter build apk --release
```
_Not: Eğer `java.lang.IllegalArgumentException: 26.0.1` şeklinde bir hata alırsanız, lütfen sisteminizde **Java 17 veya 21** yüklü ve aktif olduğundan emin olun._

## 🤝 Katkıda Bulunma
Bu proje bir üniversite dönemi ödevidir. Katkıda bulunmak için pull request gönderebilir veya karşılaştığınız sorunları "Issues" sekmesinden bildirebilirsiniz.
