# NetBakiye 💰

NetBakiye, modern ve kullanıcı dostu bir kişisel finans yönetim uygulamasıdır. Gelirlerinizi, giderlerinizi, varlıklarınızı ve tasarruf hedeflerinizi tek bir yerden takip etmenizi sağlar.

## 🚀 Özellikler

- **Özet Panosu (Dashboard):** Toplam bakiyenizi, aylık gelir ve gider dağılımınızı grafiklerle takip edin.
- **Bütçe Yönetimi:** Farklı kategoriler için bütçe limitleri belirleyin ve harcamalarınızı kontrol altında tutun.
- **Hesap ve Varlık Takibi:** Banka hesaplarınızı, nakit paranızı ve diğer varlıklarınızı yönetin.
- **Tasarruf Hedefleri:** Hayallerinizdeki şeyler için hedefler oluşturun ve ilerlemenizi görün.
- **İşlem Geçmişi:** Tüm finansal hareketlerinizi detaylıca kaydedin ve listeleyin.

## 🛠️ Teknoloji Yığını

- **Framework:** [Flutter](https://flutter.dev)
- **State Management:** [Riverpod](https://riverpod.dev)
- **Backend:** [Supabase](https://supabase.com) (Database & Auth)
- **Navigation:** [Go Router](https://pub.dev/packages/go_router)
- **Charts:** [FL Chart](https://pub.dev/packages/fl_chart)

## 📦 Kurulum

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları izleyin:

1.  **Repoyu klonlayın:**
    ```bash
    git clone https://github.com/kullaniciadi/netbakiye.git
    ```
2.  **Bağımlılıkları yükleyin:**
    ```bash
    flutter pub get
    ```
3.  **Supabase yapılandırmasını yapın:**
    `lib/main.dart` içerisindeki Supabase URL ve anon key bilgilerini kendi projenize göre güncelleyin.
4.  **Uygulamayı çalıştırın:**
    ```bash
    flutter run
    ```

## 📂 Proje Yapısı

- `lib/models`: Veri modelleri ve JSON serileştirme.
- `lib/providers`: Riverpod state provider'ları.
- `lib/screens`: Uygulama arayüzü (Dashboard, Auth, Budget vb.).
- `lib/services`: Supabase entegrasyonu ve API servisleri.
- `lib/theme`: Renk paleti ve yazı tipleri (Dark mode desteği).
