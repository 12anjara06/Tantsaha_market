import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/data_service.dart';

class MarketProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  String _selectedProductId = 'riz';
  String _selectedRegionId = 'analamanga';
  String _selectedCategory = 'Tous';
  bool _isBuyerMode = false;
  int _historyDays = 30;
  final List<Alert> _alerts = _defaultAlerts();

  // ─── Getters ─────────────────────────────────────────────────────────────────
  String get selectedProductId => _selectedProductId;
  String get selectedRegionId => _selectedRegionId;
  String get selectedCategory => _selectedCategory;
  bool get isBuyerMode => _isBuyerMode;
  int get historyDays => _historyDays;
  List<Alert> get alerts => List.unmodifiable(_alerts);
  List<Alert> get activeAlerts => _alerts.where((a) => a.isActive).toList();

  DataService get dataService => _dataService;

  Product? get selectedProduct => _dataService.getProductById(_selectedProductId);
  Region? get selectedRegion => _dataService.getRegionById(_selectedRegionId);

  List<Product> get filteredProducts {
    if (_selectedCategory == 'Tous') return DataService.products;
    return DataService.products.where((p) => p.category == _selectedCategory).toList();
  }

  double get currentPrice =>
      _dataService.getCurrentPrice(_selectedProductId, _selectedRegionId);

  double get currentPriceChange =>
      _dataService.getPriceChange(_selectedProductId, _selectedRegionId);

  List<double> get priceHistory =>
      _dataService.getPriceHistory(_selectedProductId, _selectedRegionId, days: _historyDays);

  int get unreadAlertsCount => _alerts.where((a) => a.triggeredPrice != null).length;

  // ─── Setters ─────────────────────────────────────────────────────────────────
  void selectProduct(String id) {
    if (_selectedProductId == id) return;
    _selectedProductId = id;
    notifyListeners();
  }

  void selectRegion(String id) {
    if (_selectedRegionId == id) return;
    _selectedRegionId = id;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleBuyerMode() {
    _isBuyerMode = !_isBuyerMode;
    notifyListeners();
  }

  void setHistoryDays(int days) {
    _historyDays = days;
    notifyListeners();
  }

  // ─── Alerts ──────────────────────────────────────────────────────────────────
  void addAlert({
    required String productId,
    required String regionId,
    required double threshold,
    required bool isAbove,
  }) {
    final product = _dataService.getProductById(productId);
    final region = _dataService.getRegionById(regionId);
    if (product == null || region == null) return;

    final currentPrice = _dataService.getCurrentPrice(productId, regionId);
    final triggered = isAbove ? currentPrice >= threshold : currentPrice <= threshold;

    _alerts.insert(
      0,
      Alert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: product.name,
        regionId: regionId,
        regionName: region.name,
        threshold: threshold,
        isAbove: isAbove,
        isActive: true,
        createdAt: DateTime.now(),
        triggeredPrice: triggered ? currentPrice : null,
      ),
    );
    notifyListeners();
  }

  void removeAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  static List<Alert> _defaultAlerts() {
    final now = DateTime.now();
    return [
      Alert(
        id: '1',
        productId: 'riz',
        productName: 'Riz',
        regionId: 'analamanga',
        regionName: 'Analamanga',
        threshold: 1400,
        isAbove: true,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 2)),
        triggeredPrice: 1450,
      ),
      Alert(
        id: '2',
        productId: 'tomate',
        productName: 'Tomate',
        regionId: 'atsinanana',
        regionName: 'Atsinanana',
        threshold: 600,
        isAbove: false,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 1)),
        triggeredPrice: null,
      ),
      Alert(
        id: '3',
        productId: 'vanille',
        productName: 'Vanille',
        regionId: 'sava',
        regionName: 'Sava',
        threshold: 90000,
        isAbove: true,
        isActive: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        triggeredPrice: null,
      ),
    ];
  }
}
