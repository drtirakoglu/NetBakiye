# NetBakiye 💰

**Modern ve Akıllı Kişisel Finans Yönetimi**

NetBakiye, karmaşık finansal tablolar yerine sade, şık ve sonuç odaklı bir deneyim sunan, Flutter ile geliştirilmiş yeni nesil bir bütçe takip uygulamasıdır. Kullanıcıların sadece harcamalarını kaydetmesini değil, "Gerçek Net Bakiye" kavramıyla tüm mal varlıklarını ve borçlarını tek bir noktadan orkestra etmelerini sağlar.

---

**NetBakiye: Modern & Intelligent Personal Finance Orchestrator**

NetBakiye is a next-generation budget tracking and wealth management application built with Flutter. It goes beyond simple expense logging to provide a holistic view of your "True Net Worth" by orchestrating assets, debts, and installment burdens in one elegant interface.

## 🌐 Canlı Demo

**[https://netbakiye-1234.web.app](https://netbakiye-1234.web.app)**

## 🚀 Özellikler

- **Özet Panosu (Dashboard):** Gerçek net bakiye, varlıklar ve borçlarınızı anlık takip edin.
- **Hızlı İşlem Girişi:** Gelir ve giderlerinizi taksit seçenekleriyle saniyeler içinde kaydedin.
- **Dinamik Tema Sistemi:** 5 farklı premium renk teması (Teal, Mor, Mavi, Turuncu, Pembe) ile uygulamayı kişiselleştirin.
- **Demo Modu:** Supabase bağlantısı olmadan, yerel verilerle tüm özellikleri keşfedin.
- **AI Röntgen Raporu:** Finansal durumunuza göre yapay zeka destekli tavsiyeler alın.
- **Tasarruf Hedefleri:** Sürpriz para girişi gibi dinamik kategorilerle birikimlerinizi yönetin.
- **Paylaşımlı Erişim:** Hesabınıza erişebilecek diğer kullanıcıları yönetin.

## 🛠️ Teknoloji Yığını

- **Framework:** [Flutter](https://flutter.dev)
- **State Management:** [Riverpod](https://riverpod.dev)
- **Backend:** [Supabase](https://supabase.com) & Local Demo Service
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

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakabilirsiniz.
