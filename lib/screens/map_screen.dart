import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../services/data_service.dart';
import '../models/models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  final DataService _ds = DataService();
  final _fmt = NumberFormat('#,###', 'fr_FR');
  String _selectedProduct = 'riz';
  String? _hoveredRegion;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProductChips(),
            _buildLegend(),
            Expanded(child: _buildMapGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carte des Prix',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Text('22 régions de Madagascar',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DataService.products.length.clamp(0, 8),
        itemBuilder: (ctx, i) {
          final p = DataService.products[i];
          final selected = p.id == _selectedProduct;
          return GestureDetector(
            onTap: () => setState(() => _selectedProduct = p.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected ? null : AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppColors.divider),
              ),
              child: Text('${p.icon} ${p.name}',
                  style: GoogleFonts.outfit(
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text('Bas ', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11)),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.warning, AppColors.danger],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(' Élevé', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMapGrid() {
    final prices = DataService.regions.map((r) {
      return MapEntry(r, _ds.getCurrentPrice(_selectedProduct, r.id));
    }).toList();

    final allPrices = prices.map((e) => e.value).toList();
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);

    return FadeTransition(
      opacity: _animation,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: prices.length,
        itemBuilder: (ctx, i) {
          final entry = prices[i];
          final pct = maxPrice > minPrice
              ? ((entry.value - minPrice) / (maxPrice - minPrice))
              : 0.5;
          final color = Color.lerp(
              AppColors.success, AppColors.danger, pct)!;
          final isTop = entry.value == maxPrice;
          final isBest = entry.value == minPrice;

          return GestureDetector(
            onTap: () => _showRegionDetail(entry.key, entry.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: color.withAlpha(60),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _hoveredRegion == entry.key.id
                        ? Colors.white
                        : color.withAlpha(120),
                    width: _hoveredRegion == entry.key.id ? 2 : 1),
              ),
              child: Stack(
                children: [
                  if (isTop)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withAlpha(180),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('▲', style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    ),
                  if (isBest)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('★', style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(entry.key.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('${_fmt.format(entry.value.toInt())} Ar',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                        Text(_ds.getTrend(_selectedProduct, entry.key.id) ==
                                    PriceTrend.up
                                ? '▲ ${_ds.getPriceChange(_selectedProduct, entry.key.id).toStringAsFixed(1)}%'
                                : _ds.getTrend(
                                            _selectedProduct, entry.key.id) ==
                                        PriceTrend.down
                                    ? '▼ ${_ds.getPriceChange(_selectedProduct, entry.key.id).abs().toStringAsFixed(1)}%'
                                    : '— stable',
                            style: GoogleFonts.outfit(
                                color: Colors.white70, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRegionDetail(Region region, double price) {
    // Get all products for this region
    final productPrices = DataService.products.take(8).map((p) {
      return MapEntry(p, _ds.getCurrentPrice(p.id, region.id));
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(region.name,
                            style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text('Chef-lieu: ${region.capital}',
                            style: GoogleFonts.outfit(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: productPrices.length,
                itemBuilder: (ctx, i) {
                  final entry = productPrices[i];
                  final change = _ds.getPriceChange(entry.key.id, region.id);
                  final isUp = change > 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(entry.key.icon,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(entry.key.name,
                              style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Text('${_fmt.format(entry.value.toInt())} Ar',
                            style: GoogleFonts.outfit(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text(
                            '${isUp ? '▲' : '▼'} ${change.abs().toStringAsFixed(1)}%',
                            style: GoogleFonts.outfit(
                                color: isUp
                                    ? AppColors.danger
                                    : AppColors.success,
                                fontSize: 11)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
