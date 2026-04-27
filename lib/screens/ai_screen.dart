import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../services/ai_service.dart';
import '../services/data_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  final AiService _aiService = AiService();
  final DataService _ds = DataService();
  final _fmt = NumberFormat('#,###', 'fr_FR');
  String _selectedProductId = 'riz';
  String _selectedRegionId = 'analamanga';
  int _horizon = 30;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _animation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _refresh() {
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _aiService.getBestSellingRecommendations(
      _selectedProductId,
      horizons: [7, 14, 30],
    );
    final topRecs = recommendations.where((r) => r.gainPercent > 0).take(5).toList();
    final history = _ds.getPriceHistory(_selectedProductId, _selectedRegionId, days: 30);
    final predicted = _aiService.predictPrices(_selectedProductId, _selectedRegionId, horizon: _horizon);
    final product = DataService.products.firstWhere((p) => p.id == _selectedProductId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildProductRegionSelectors()),
            SliverToBoxAdapter(
                child: _buildChart(history, predicted, product.unit)),
            SliverToBoxAdapter(child: _buildHorizonSelector()),
            SliverToBoxAdapter(child: _buildPredictionSummary(predicted, history)),
            if (topRecs.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('🏆 Meilleures recommandations',
                      style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildRecommendationCard(topRecs[i], i),
                    childCount: topRecs.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prédiction des prix',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Machine Learning — Régression Linéaire',
                    style: GoogleFonts.outfit(
                        color: AppColors.primaryLight, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRegionSelectors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown<String>(
              value: _selectedProductId,
              items: DataService.products
                  .map((p) => DropdownMenuItem(
                      value: p.id, child: Text('${p.icon} ${p.name}')))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedProductId = v!);
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdown<String>(
              value: _selectedRegionId,
              items: DataService.regions
                  .map((r) =>
                      DropdownMenuItem(value: r.id, child: Text(r.name)))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedRegionId = v!);
                _refresh();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        style:
            GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildHorizonSelector() {
    final horizons = {'7 jours': 7, '14 jours': 14, '30 jours': 30};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text('Prédiction sur:',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 10),
          ...horizons.entries.map((e) {
            final selected = _horizon == e.value;
            return GestureDetector(
              onTap: () {
                setState(() => _horizon = e.value);
                _refresh();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.goldGradient : null,
                  color: selected ? null : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : AppColors.divider),
                ),
                child: Text(e.key,
                    style: GoogleFonts.outfit(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChart(
      List<double> history, List<double> predicted, String unit) {
    final allValues = [...history, ...predicted];
    if (allValues.isEmpty) return const SizedBox(height: 200);
    final maxY = allValues.reduce((a, b) => a > b ? a : b) * 1.15;
    final minY = allValues.reduce((a, b) => a < b ? a : b) * 0.85;

    final historySpots = history.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final predOffset = history.length.toDouble();
    final predSpots = predicted.asMap().entries
        .map((e) => FlSpot(predOffset + e.key, e.value))
        .toList();

    return AnimatedBuilder(
      animation: _animation,
      builder: (ctx, _) {
        final cut = (_animation.value * predSpots.length).floor();
        final visiblePred = predSpots.sublist(0, cut.clamp(0, predSpots.length));

        return SizedBox(
          height: 230,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.divider.withAlpha(100), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 58,
                      getTitlesWidget: (v, meta) => Text(
                          _fmt.format(v.toInt()),
                          style: GoogleFonts.outfit(
                              color: AppColors.textSecondary, fontSize: 9)),
                    ),
                  ),
                ),
                lineBarsData: [
                  // Historical
                  LineChartBarData(
                    spots: historySpots,
                    isCurved: true,
                    color: AppColors.primaryLight,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryLight.withAlpha(80),
                          AppColors.primaryLight.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
                  // Predicted
                  if (visiblePred.isNotEmpty)
                    LineChartBarData(
                      spots: [historySpots.last, ...visiblePred],
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 2.5,
                      dashArray: [6, 4],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (s, _, __, i) {
                          if (i != visiblePred.length) {
                            return FlDotCirclePainter(
                                radius: 0, color: Colors.transparent);
                          }
                          return FlDotCirclePainter(
                              radius: 5,
                              color: AppColors.accent,
                              strokeColor: Colors.white,
                              strokeWidth: 2);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accent.withAlpha(60),
                            AppColors.accent.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionSummary(List<double> predicted, List<double> history) {
    if (predicted.isEmpty || history.isEmpty) return const SizedBox.shrink();
    final currentPrice = history.last;
    final endPrice = predicted.last;
    final change = ((endPrice - currentPrice) / currentPrice) * 100;
    final isUp = change > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isUp
                ? AppColors.danger.withAlpha(80)
                : AppColors.success.withAlpha(80)),
      ),
      child: Row(
        children: [
          Text(isUp ? '📈' : '📉', style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prédiction à $_horizon jours',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 12)),
                Text(
                    '${_fmt.format(endPrice.toInt())} Ar (${isUp ? '+' : ''}${change.toStringAsFixed(1)}%)',
                    style: GoogleFonts.outfit(
                        color: isUp ? AppColors.danger : AppColors.success,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text(isUp
                    ? '⚠️ Vendez maintenant ou attendez le pic'
                    : '✅ Bon moment pour acheter',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic rec, int rank) {
    final icons = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rank == 0
            ? AppColors.primary.withAlpha(50)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: rank == 0
                ? AppColors.primaryLight.withAlpha(120)
                : AppColors.divider),
      ),
      child: Row(
        children: [
          Text(icons[rank], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.regionName,
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('Dans ${rec.daysFromNow} jours • Confiance: ${rec.confidence.toStringAsFixed(0)}%',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_fmt.format(rec.predictedPrice.toInt())} Ar',
                  style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text('+${rec.gainPercent.toStringAsFixed(1)}%',
                  style: GoogleFonts.outfit(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
