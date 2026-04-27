import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/market_provider.dart';
import '../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;
  final _fmt = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _chartAnimation =
        CurvedAnimation(parent: _chartController, curve: Curves.easeInOut);
    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketProvider>();
    final product = provider.selectedProduct;
    final region = provider.selectedRegion;
    final history = provider.priceHistory;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSelectors(provider),
            _buildPeriodSelector(provider),
            if (product != null && region != null && history.isNotEmpty)
              ...[
                _buildStatRow(history, product.unit),
                Expanded(child: _buildChart(history, product.unit)),
              ]
            else
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryLight))),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text('Historique des Prix',
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSelectors(MarketProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown<String>(
              value: provider.selectedProductId,
              items: DataService.products
                  .map((p) => DropdownMenuItem(
                      value: p.id, child: Text('${p.icon} ${p.name}')))
                  .toList(),
              onChanged: (v) => provider.selectProduct(v!),
              hint: 'Produit',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown<String>(
              value: provider.selectedRegionId,
              items: DataService.regions
                  .map((r) =>
                      DropdownMenuItem(value: r.id, child: Text(r.name)))
                  .toList(),
              onChanged: (v) => provider.selectRegion(v!),
              hint: 'Région',
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
    required String hint,
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
        style: GoogleFonts.outfit(
            color: AppColors.textPrimary, fontSize: 13),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildPeriodSelector(MarketProvider provider) {
    const periods = {'30j': 30, '60j': 60, '90j': 90};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: periods.entries.map((e) {
          final selected = provider.historyDays == e.value;
          return GestureDetector(
            onTap: () {
              provider.setHistoryDays(e.value);
              _chartController.reset();
              _chartController.forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient:
                    selected ? AppColors.primaryGradient : null,
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
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatRow(List<double> history, String unit) {
    final min = history.reduce((a, b) => a < b ? a : b);
    final max = history.reduce((a, b) => a > b ? a : b);
    final avg = history.reduce((a, b) => a + b) / history.length;
    final change =
        history.length > 1 ? ((history.last - history.first) / history.first) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildStatChip('Min', '${_fmt.format(min)} Ar', AppColors.success),
          const SizedBox(width: 8),
          _buildStatChip('Max', '${_fmt.format(max)} Ar', AppColors.danger),
          const SizedBox(width: 8),
          _buildStatChip('Moy', '${_fmt.format(avg.round())} Ar',
              AppColors.accent),
          const SizedBox(width: 8),
          _buildStatChip(
              'Variation',
              '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
              change >= 0 ? AppColors.danger : AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.outfit(
                    color: AppColors.textSecondary, fontSize: 10)),
            Text(value,
                style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<double> history, String unit) {
    final maxY = (history.reduce((a, b) => a > b ? a : b) * 1.15);
    final minY = (history.reduce((a, b) => a < b ? a : b) * 0.85);

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (ctx, _) {
        final cutoff = (_chartAnimation.value * spots.length).floor();
        final visibleSpots =
            spots.sublist(0, cutoff.clamp(1, spots.length));

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.divider.withAlpha(120), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (history.length / 4).ceilToDouble(),
                    getTitlesWidget: (v, meta) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= history.length) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime.now().subtract(
                          Duration(days: history.length - 1 - idx));
                      return Text(DateFormat('dd/MM').format(date),
                          style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 9));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (v, meta) => Text(
                        _fmt.format(v.toInt()),
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary, fontSize: 9)),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: visibleSpots,
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
                        AppColors.primaryLight.withAlpha(100),
                        AppColors.primaryLight.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surface,
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            '${_fmt.format(s.y.toInt())} Ar/$unit',
                            GoogleFonts.outfit(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
