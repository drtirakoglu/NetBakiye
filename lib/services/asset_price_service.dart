import 'dart:async';
import 'dart:math';

class AssetPrice {
  final String symbol;
  final double price;
  final double change;

  AssetPrice({required this.symbol, required this.price, required this.change});
}

class AssetPriceService {
  final _controller = StreamController<List<AssetPrice>>.broadcast();
  Timer? _timer;
  
  // Base prices
  final Map<String, double> _basePrices = {
    'XAU': 2450.0, // Gold (Ounce)
    'USD': 32.20,  // USD/TRY
    'EUR': 35.10,  // EUR/TRY
    'BIST': 9150.0, // BIST 100
  };

  Stream<List<AssetPrice>> get priceStream => _controller.stream;

  void startSimulating() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final random = Random();
      final updates = _basePrices.entries.map((entry) {
        final changePercent = (random.nextDouble() - 0.5) * 0.01; // Max 0.5% change
        final newPrice = entry.value * (1 + changePercent);
        _basePrices[entry.key] = newPrice;
        return AssetPrice(
          symbol: entry.key,
          price: newPrice,
          change: changePercent * 100,
        );
      }).toList();
      _controller.add(updates);
    });
  }

  void stopSimulating() {
    _timer?.cancel();
  }

  void dispose() {
    stopSimulating();
    _controller.close();
  }
}
