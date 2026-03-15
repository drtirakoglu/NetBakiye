# Katkıda Bulunma Rehberi (Contributing Guidelines)

NetBakiye'ye katkıda bulunmak istediğiniz için teşekkürler! 🎉 

Bu proje, açık kaynak topluluğunun desteğiyle büyümeyi hedefliyor. Katkıda bulunurken lütfen aşağıdaki adımları ve kuralları takip edin.

## 🚀 Başlarken

1.  Projenin bir kopyasını kendinize [fork](https://github.com/drtirakoglu/NetBakiye/fork) edin.
2.  Yerel ortamınızda yeni bir dal (branch) oluşturun:
    ```bash
    git checkout -b ozellik/harika-yeni-ozellik
    ```
3.  Değişikliklerinizi yapın ve test edin.
4.  Commit'leyip (anlamlı mesajlar kullanarak) fork'unuza gönderin.
5.  Orijinal repoya bir **Pull Request (PR)** açın.

## 🛠️ Geliştirme Standartları

*   **Flutter & Dart:** Kod yazarken [resmi Dart stil rehberine](https://dart.dev/guides/language/effective-dart/style) uymaya çalışın.
*   **İsimlendirme:** Değişken ve fonksiyon isimleri `camelCase`, sınıflar `PascalCase` olmalıdır.
*   **Yorum Satırları:** Karmaşık mantık içeren yerlerde açıklayıcı yorumlar ekleyin.
*   **Riverpod:** State yönetimi için Riverpod kullanımına özen gösterin.

## 🐛 Hata Bildirimi (Issue Reporting)

Eğer bir hata bulduysanız veya yeni bir özellik öneriniz varsa, lütfen [Issues](https://github.com/drtirakoglu/NetBakiye/issues) sekmesi üzerinden bildirin. Bildirirken şunları eklediğinizden emin olun:
- Hatanın kısa ve öz açıklaması.
- Hatayı yeniden oluşturmak için izlenecek adımlar.
- Beklenen sonuç ve gerçekleşen sonuç.
- (Mümkünse) Ekran görüntüsü veya log çıktıları.

## 🤝 Davranış Kuralları

Projeye katkıda bulunurken lütfen [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) dosyasındaki kurallara uyun. Herkese karşı saygılı ve nazik olun.

## ✅ Pull Request Kontrol Listesi

PR göndermeden önce şunları kontrol edin:
- [ ] `flutter analyze` komutu hata veya uyarı vermiyor.
- [ ] Kodunuz mevcut mimarı yapıya (lib/models, lib/providers vb.) uyuyor.
- [ ] Yeni bir özellik eklediyseniz, gerekiyorsa README'yi güncellediniz.

Sorularınız olursa Issue açmaktan çekinmeyin. İyi kodlamalar! 💻
