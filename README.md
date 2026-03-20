# NetBakiye 💰

**Modern ve Akıllı Kişisel Finans Yönetimi**

NetBakiye, karmaşık finansal tablolar yerine sade, şık ve sonuç odaklı bir deneyim sunan, Flutter ile geliştirilmiş yeni nesil bir bütçe takip uygulamasıdır. Kullanıcıların sadece harcamalarını kaydetmesini değil, "Gerçek Net Bakiye" kavramıyla tüm mal varlıklarını ve borçlarını tek bir noktadan orkestra etmelerini sağlar.

---

**NetBakiye: Modern & Intelligent Personal Finance Orchestrator**

NetBakiye is a next-generation budget tracking and wealth management application built with Flutter. It goes beyond simple expense logging to provide a holistic view of your "True Net Worth" by orchestrating assets, debts, and installment burdens in one elegant interface.

## 🌐 Canlı Demo

**[https://netbakiye-1234.web.app](https://netbakiye-1234.web.app)**

## 🚀 Özellikler

### 🏠 Özet Panosu (Dashboard)
- Gerçek net bakiye, varlıklar ve borçları anlık takip
- **Nakit Akışı Trendi:** Son 6 aylık çizgi grafiği
- **En Çok Harcanan Kategoriler:** Sıralı progress bar'lar ile görsel kırılım
- **Yaklaşan Ödemeler:** 7 günlük mini ödeme listesi
- **Bütçe Özeti:** Allocated vs Spent karşılaştırmalı progress bar'lar
- **Güvenli Harcama Limiti:** Faiz maliyeti düşüldükten sonra harcanabilir tutar

### 📋 İşlem Geçmişi & Filtreleme
- Tarih gruplu liste (Bugün / Dün / Bu Hafta / Bu Ay)
- Ad ve not bazlı arama
- Hesap, kategori, dönem ve gelir/gider filtresi
- Kaydırarak silme (swipe-to-delete)
- Gelir/gider özet satırı

### 📊 Raporlar
- Dönem seçici (Bu Hafta / Bu Ay / Bu Yıl)
- Kategoriye göre interaktif pasta grafiği
- Gelir–Gider karşılaştırma çubuk grafiği
- Birikim oranı göstergesi
- Kategori dağılım listesi (% ve tutar)

### 📅 Takvim
- Aylık ızgara görünümü
- İşlem ve sabit ödemelerin renkli nokta/badge ile gösterimi
- Güne tıklayarak o günün işlem ve ödemelerini görme

### ➕ Gelişmiş İşlem Ekleme
- Hesap seçici dropdown
- Not alanı
- Taksit seçenekleri
- Kategori seçici

### ⚙️ Diğer
- **Demo Modu:** Supabase bağlantısı olmadan tüm özellikleri keşfedin
- **Dinamik Tema Sistemi:** 5 farklı premium renk teması (Teal, Mor, Mavi, Turuncu, Pembe)
- **AI Röntgen Raporu:** Finansal durumunuza göre yapay zeka destekli tavsiyeler
- **Tasarruf Hedefleri:** Dinamik kategorilerle birikim yönetimi
- **Paylaşımlı Erişim:** Hesabınıza erişebilecek kullanıcıları yönetin

## 🛠️ Teknoloji Yığını

- **Framework:** [Flutter](https://flutter.dev)
- **State Management:** [Riverpod](https://riverpod.dev)
- **Backend:** [Supabase](https://supabase.com) & Local Demo Service
- **Navigation:** [Go Router](https://pub.dev/packages/go_router)
- **Charts:** [FL Chart](https://pub.dev/packages/fl_chart)
- **Hosting:** [Firebase Hosting](https://firebase.google.com/products/hosting)

## 📦 Kurulum

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları izleyin:

1. **Repoyu klonlayın:**
   ```bash
   git clone https://github.com/drtirakoglu/NetBakiye.git
   ```
2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Supabase yapılandırmasını yapın:**
   `lib/main.dart` içerisindeki Supabase URL ve anon key bilgilerini kendi projenize göre güncelleyin.
4. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

## 📂 Proje Yapısı

- `lib/models`: Veri modelleri ve JSON serileştirme.
- `lib/providers`: Riverpod state provider'ları.
- `lib/screens`: Uygulama arayüzü (Dashboard, İşlemler, Raporlar, Takvim vb.).
- `lib/services`: Supabase entegrasyonu ve Demo servisi.
- `lib/theme`: Renk paleti ve yazı tipleri (Dark mode desteği).

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakabilirsiniz.
