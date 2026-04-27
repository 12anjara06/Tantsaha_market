class Product {
  final String id;
  final String name;
  final String icon;
  final String category;
  final String unit;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.unit,
    required this.description,
  });
}

class Region {
  final String id;
  final String name;
  final String capital;

  const Region({
    required this.id,
    required this.name,
    required this.capital,
  });
}

enum PriceTrend { up, down, stable }

class PriceEntry {
  final String productId;
  final String regionId;
  final double price;
  final DateTime date;
  final PriceTrend trend;
  final double changePercent;

  const PriceEntry({
    required this.productId,
    required this.regionId,
    required this.price,
    required this.date,
    required this.trend,
    required this.changePercent,
  });
}

class Alert {
  final String id;
  final String productId;
  final String productName;
  final String regionId;
  final String regionName;
  final double threshold;
  final bool isAbove;
  final bool isActive;
  final DateTime createdAt;
  final double? triggeredPrice;

  const Alert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.regionId,
    required this.regionName,
    required this.threshold,
    required this.isAbove,
    required this.isActive,
    required this.createdAt,
    this.triggeredPrice,
  });
}
