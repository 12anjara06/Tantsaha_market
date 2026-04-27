import 'dart:math';
import '../models/models.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal() {
    _generateHistoricalData();
  }

  final Random _random = Random(42);

  // ─── Products ───────────────────────────────────────────────────────────────
  static const List<Product> products = [
    Product(id: 'riz', name: 'Riz', icon: '🌾', category: 'Céréales', unit: 'kg', description: 'Riz blanc local'),
    Product(id: 'mais', name: 'Maïs', icon: '🌽', category: 'Céréales', unit: 'kg', description: 'Maïs jaune'),
    Product(id: 'manioc', name: 'Manioc', icon: '🥔', category: 'Céréales', unit: 'kg', description: 'Manioc frais'),
    Product(id: 'patate', name: 'Patate douce', icon: '🍠', category: 'Légumes', unit: 'kg', description: 'Patate douce'),
    Product(id: 'tomate', name: 'Tomate', icon: '🍅', category: 'Légumes', unit: 'kg', description: 'Tomate locale'),
    Product(id: 'oignon', name: 'Oignon', icon: '🧅', category: 'Légumes', unit: 'kg', description: 'Oignon rouge'),
    Product(id: 'ail', name: 'Ail', icon: '🧄', category: 'Épices', unit: 'kg', description: 'Ail frais'),
    Product(id: 'piment', name: 'Piment', icon: '🌶️', category: 'Épices', unit: 'kg', description: 'Piment rouge'),
    Product(id: 'gingembre', name: 'Gingembre', icon: '🫚', category: 'Épices', unit: 'kg', description: 'Gingembre frais'),
    Product(id: 'vanille', name: 'Vanille', icon: '🌿', category: 'Épices', unit: 'kg', description: 'Vanille de Sava'),
    Product(id: 'haricot', name: 'Haricot', icon: '🫘', category: 'Légumineuses', unit: 'kg', description: 'Haricot rouge'),
    Product(id: 'arachide', name: 'Arachide', icon: '🥜', category: 'Légumineuses', unit: 'kg', description: 'Arachide grillée'),
    Product(id: 'banana', name: 'Banane', icon: '🍌', category: 'Fruits', unit: 'kg', description: 'Banane jaune'),
    Product(id: 'mangue', name: 'Mangue', icon: '🥭', category: 'Fruits', unit: 'kg', description: 'Mangue fraîche'),
    Product(id: 'litchi', name: 'Litchi', icon: '🍒', category: 'Fruits', unit: 'kg', description: 'Litchi de Tamatave'),
    Product(id: 'ananas', name: 'Ananas', icon: '🍍', category: 'Fruits', unit: 'pièce', description: 'Ananas frais'),
    Product(id: 'pomme_terre', name: 'Pomme de terre', icon: '🥔', category: 'Légumes', unit: 'kg', description: 'Pomde de terre'),
    Product(id: 'carotte', name: 'Carotte', icon: '🥕', category: 'Légumes', unit: 'kg', description: 'Carotte fraîche'),
    Product(id: 'chou', name: 'Chou', icon: '🥬', category: 'Légumes', unit: 'kg', description: 'Chou vert'),
    Product(id: 'courgette', name: 'Courgette', icon: '🥒', category: 'Légumes', unit: 'kg', description: 'Courgette'),
  ];

  // ─── Regions ────────────────────────────────────────────────────────────────
  static const List<Region> regions = [
    Region(id: 'analamanga', name: 'Analamanga', capital: 'Antananarivo'),
    Region(id: 'vakinankaratra', name: 'Vakinankaratra', capital: 'Antsirabe'),
    Region(id: 'itasy', name: 'Itasy', capital: 'Miarinarivo'),
    Region(id: 'bongolava', name: 'Bongolava', capital: 'Tsiroanomandidy'),
    Region(id: 'haute_matsiatra', name: 'Haute Matsiatra', capital: 'Fianarantsoa'),
    Region(id: 'amoron_i_mania', name: "Amoron'i Mania", capital: 'Ambositra'),
    Region(id: 'vatovavy_fitovinany', name: 'Vatovavy-Fitovinany', capital: 'Manakara'),
    Region(id: 'ihorombe', name: 'Ihorombe', capital: 'Ihosy'),
    Region(id: 'atsimo_atsinanana', name: 'Atsimo-Atsinanana', capital: 'Farafangana'),
    Region(id: 'atsinanana', name: 'Atsinanana', capital: 'Toamasina'),
    Region(id: 'analanjirofo', name: 'Analanjirofo', capital: 'Fenoarivo'),
    Region(id: 'alaotra_mangoro', name: 'Alaotra-Mangoro', capital: 'Ambatondrazaka'),
    Region(id: 'boeny', name: 'Boeny', capital: 'Mahajanga'),
    Region(id: 'sofia', name: 'Sofia', capital: 'Antsohihy'),
    Region(id: 'betsiboka', name: 'Betsiboka', capital: 'Maevatanana'),
    Region(id: 'melaky', name: 'Melaky', capital: 'Maintirano'),
    Region(id: 'atsimo_andrefana', name: 'Atsimo-Andrefana', capital: 'Toliara'),
    Region(id: 'androy', name: 'Androy', capital: 'Ambovombe'),
    Region(id: 'anosy', name: 'Anosy', capital: 'Tolagnaro'),
    Region(id: 'menabe', name: 'Menabe', capital: 'Morondava'),
    Region(id: 'diana', name: 'Diana', capital: 'Antsiranana'),
    Region(id: 'sava', name: 'Sava', capital: 'Sambava'),
  ];

  // ─── Base Prices (Ar/kg) ─────────────────────────────────────────────────────
  static const Map<String, double> _basePrices = {
    'riz': 1200,
    'mais': 600,
    'manioc': 400,
    'patate': 500,
    'tomate': 800,
    'oignon': 1500,
    'ail': 8000,
    'piment': 3000,
    'gingembre': 4000,
    'vanille': 80000,
    'haricot': 2500,
    'arachide': 3500,
    'banana': 600,
    'mangue': 700,
    'litchi': 1200,
    'ananas': 1000,
    'pomme_terre': 900,
    'carotte': 1100,
    'chou': 700,
    'courgette': 800,
  };

  // Historical price data: productId → regionId → list of daily prices (90 days)
  final Map<String, Map<String, List<double>>> _historicalPrices = {};

  void _generateHistoricalData() {
    for (final product in products) {
      _historicalPrices[product.id] = {};
      final base = _basePrices[product.id] ?? 1000;

      for (final region in regions) {
        // Each region has a regional multiplier (0.7 to 1.4)
        final regionalFactor = 0.7 + _seededRandom(product.id + region.id) * 0.7;
        final List<double> prices = [];
        double current = base * regionalFactor;

        for (int day = 89; day >= 0; day--) {
          // Random walk with slight upward bias
          final change = ((_random.nextDouble() - 0.48) * 0.06);
          current = (current * (1 + change)).clamp(base * 0.3, base * 2.5);
          prices.add(current.roundToDouble());
        }
        _historicalPrices[product.id]![region.id] = prices;
      }
    }
  }

  double _seededRandom(String seed) {
    int hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return (hash % 1000) / 1000.0;
  }

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Dernier prix d'un produit dans une région
  double getCurrentPrice(String productId, String regionId) {
    return _historicalPrices[productId]?[regionId]?.last ?? 0;
  }

  /// Variation % des derniers 7 jours
  double getPriceChange(String productId, String regionId) {
    final prices = _historicalPrices[productId]?[regionId];
    if (prices == null || prices.length < 8) return 0;
    final current = prices.last;
    final weekAgo = prices[prices.length - 8];
    if (weekAgo == 0) return 0;
    return ((current - weekAgo) / weekAgo) * 100;
  }

  PriceTrend getTrend(String productId, String regionId) {
    final change = getPriceChange(productId, regionId);
    if (change > 1) return PriceTrend.up;
    if (change < -1) return PriceTrend.down;
    return PriceTrend.stable;
  }

  /// Historique des prix sur N jours
  List<double> getPriceHistory(String productId, String regionId, {int days = 30}) {
    final prices = _historicalPrices[productId]?[regionId] ?? [];
    if (prices.length <= days) return List.from(prices);
    return prices.sublist(prices.length - days);
  }

  /// Prix de tous les produits dans toutes les régions (snapshot actuel)
  List<PriceEntry> getCurrentPrices() {
    final List<PriceEntry> entries = [];
    final now = DateTime.now();
    for (final product in products) {
      for (final region in regions) {
        final price = getCurrentPrice(product.id, region.id);
        final change = getPriceChange(product.id, region.id);
        entries.add(PriceEntry(
          productId: product.id,
          regionId: region.id,
          price: price,
          date: now,
          trend: getTrend(product.id, region.id),
          changePercent: change,
        ));
      }
    }
    return entries;
  }

  /// Meilleure région pour vendre un produit (prix le plus élevé)
  Region getBestSellingRegion(String productId) {
    Region best = regions.first;
    double bestPrice = 0;
    for (final region in regions) {
      final price = getCurrentPrice(productId, region.id);
      if (price > bestPrice) {
        bestPrice = price;
        best = region;
      }
    }
    return best;
  }

  /// Prix moyen national d'un produit
  double getNationalAveragePrice(String productId) {
    double total = 0;
    for (final region in regions) {
      total += getCurrentPrice(productId, region.id);
    }
    return total / regions.length;
  }

  /// Top 5 produits avec la plus forte hausse cette semaine
  List<Product> getTopRisingProducts() {
    final List<MapEntry<Product, double>> entries = products.map((p) {
      double maxChange = 0;
      for (final r in regions) {
        final c = getPriceChange(p.id, r.id);
        if (c > maxChange) maxChange = c;
      }
      return MapEntry(p, maxChange);
    }).toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).map((e) => e.key).toList();
  }

  /// Prix d'un produit dans toutes les régions (trié par prix)
  List<MapEntry<Region, double>> getPricesByRegion(String productId, {bool ascending = true}) {
    final entries = regions.map((r) {
      return MapEntry(r, getCurrentPrice(productId, r.id));
    }).toList();
    entries.sort((a, b) => ascending ? a.value.compareTo(b.value) : b.value.compareTo(a.value));
    return entries;
  }

  Product? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Region? getRegionById(String id) {
    try {
      return regions.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
