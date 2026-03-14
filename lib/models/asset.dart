enum AssetType { ceyrekAltin, gramAltin, usd, eur, other }

class AppAsset {
  final String id;
  final String userId;
  final AssetType type;
  final String? name;
  final double quantity;
  final double purchasePriceTry;

  AppAsset({
    required this.id,
    required this.userId,
    required this.type,
    this.name,
    this.quantity = 0.0,
    this.purchasePriceTry = 0.0,
  });

  factory AppAsset.fromJson(Map<String, dynamic> json) {
    return AppAsset(
      id: json['id'],
      userId: json['user_id'],
      type: AssetType.values.firstWhere((e) {
        final val = json['type'] as String;
        if (val == 'ceyrek_altin') return e == AssetType.ceyrekAltin;
        if (val == 'gram_altin') return e == AssetType.gramAltin;
        return e.toString().split('.').last == val;
      }),
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      purchasePriceTry: (json['purchase_price_try'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type == AssetType.ceyrekAltin
          ? 'ceyrek_altin'
          : type == AssetType.gramAltin
              ? 'gram_altin'
              : type.toString().split('.').last,
      'name': name,
      'quantity': quantity,
      'purchase_price_try': purchasePriceTry,
    };
  }
}
