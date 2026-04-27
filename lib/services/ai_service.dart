import '../services/data_service.dart';

class AiPrediction {
  final String regionId;
  final String regionName;
  final double predictedPrice;
  final double currentPrice;
  final double gainPercent;
  final int daysFromNow;
  final double confidence;

  const AiPrediction({
    required this.regionId,
    required this.regionName,
    required this.predictedPrice,
    required this.currentPrice,
    required this.gainPercent,
    required this.daysFromNow,
    required this.confidence,
  });
}

class AiService {
  final DataService _dataService = DataService();

  /// Régression linéaire simple sur l'historique
  _LinearModel _fitLinear(List<double> prices) {
    final n = prices.length;
    if (n < 2) return const _LinearModel(slope: 0, intercept: 0);

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += prices[i];
      sumXY += i * prices[i];
      sumX2 += i * i;
    }

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return _LinearModel(slope: 0, intercept: sumY / n);

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;
    return _LinearModel(slope: slope, intercept: intercept);
  }

  double _predict(_LinearModel model, int x) {
    return model.slope * x + model.intercept;
  }

  /// Coefficient de détermination R²  (0..1)
  double _r2(List<double> actual, _LinearModel model) {
    final mean = actual.reduce((a, b) => a + b) / actual.length;
    double ssTot = 0, ssRes = 0;
    for (int i = 0; i < actual.length; i++) {
      ssTot += (actual[i] - mean) * (actual[i] - mean);
      ssRes += (actual[i] - _predict(model, i)) * (actual[i] - _predict(model, i));
    }
    if (ssTot == 0) return 1;
    return (1 - ssRes / ssTot).clamp(0.0, 1.0);
  }

  /// Prédire les prix d'un produit dans une région pour les prochains N jours
  List<double> predictPrices(String productId, String regionId, {int horizon = 30}) {
    final history = _dataService.getPriceHistory(productId, regionId, days: 60);
    final model = _fitLinear(history);
    final n = history.length;

    return List.generate(horizon, (i) {
      final raw = _predict(model, n + i);
      return raw.clamp(100.0, 200000.0);
    });
  }

  /// Trouver la meilleure région et la meilleure période pour vendre
  List<AiPrediction> getBestSellingRecommendations(
    String productId, {
    List<int> horizons = const [7, 14, 30],
  }) {
    final List<AiPrediction> predictions = [];

    for (final region in DataService.regions) {
      final history = _dataService.getPriceHistory(productId, region.id, days: 60);
      final model = _fitLinear(history);
      final r2 = _r2(history, model);
      final confidence = (r2 * 100).clamp(30.0, 95.0);
      final currentPrice = _dataService.getCurrentPrice(productId, region.id);
      final n = history.length;

      for (final days in horizons) {
        final predicted = _predict(model, n + days).clamp(100.0, 200000.0);
        final gain = currentPrice > 0 ? ((predicted - currentPrice) / currentPrice) * 100 : 0.0;

        predictions.add(AiPrediction(
          regionId: region.id,
          regionName: region.name,
          predictedPrice: predicted,
          currentPrice: currentPrice,
          gainPercent: gain,
          daysFromNow: days,
          confidence: confidence,
        ));
      }
    }

    // Sort by predicted gain descending
    predictions.sort((a, b) => b.gainPercent.compareTo(a.gainPercent));
    return predictions;
  }
}

class _LinearModel {
  final double slope;
  final double intercept;
  const _LinearModel({required this.slope, required this.intercept});
}
