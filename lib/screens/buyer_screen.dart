import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../services/data_service.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  final _fmt = NumberFormat('#,###', 'fr_FR');
  final DataService _ds = DataService();
  String _selectedProductId = 'riz';

  @override
  Widget build(BuildContext context) {
    final regionPrices = _ds.getPricesByRegion(_selectedProductId);
    final product = DataService.products
        .firstWhere((p) => p.id == _selectedProductId);
    final minPrice = regionPrices.first.value;
    final maxPrice = regionPrices.last.value;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProductSelector(),
            _buildSummaryBanner(product, minPrice, maxPrice),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: regionPrices.length,
                itemBuilder: (ctx, i) =>
                    _buildRegionRow(regionPrices[i], i, minPrice, maxPrice, product),
              ),
            ),
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
          const Text('🏢', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Espace Grossistes',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Text('Trouvez le meilleur prix d\'achat',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withAlpha(80)),
            ),
            child: Text('GROSSISTE',
                style: GoogleFonts.outfit(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: DataService.products.length,
          itemBuilder: (ctx, i) {
            final p = DataService.products[i];
            final selected = p.id == _selectedProductId;
            return GestureDetector(
              onTap: () => setState(() => _selectedProductId = p.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected ? null : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(22),
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
      ),
    );
  }

  Widget _buildSummaryBanner(
      Product product, double minPrice, double maxPrice) {
    final savings =
        (((maxPrice - minPrice) / maxPrice) * 100).toStringAsFixed(0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(product.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: GoogleFonts.outfit(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text('Achetez là où c\'est le moins cher',
                    style: GoogleFonts.outfit(
                        color: AppColors.primary.withAlpha(180),
                        fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Économisez',
                  style: GoogleFonts.outfit(
                      color: AppColors.primary.withAlpha(180),
                      fontSize: 10)),
              Text('$savings%',
                  style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRegionRow(MapEntry<Region, double> entry, int rank,
      double minPrice, double maxPrice, Product product) {
    final price = entry.value;
    final pctAbove = maxPrice > minPrice
        ? ((price - minPrice) / (maxPrice - minPrice) * 100)
        : 50.0;
    final isBest = rank == 0;
    final trend = _ds.getTrend(product.id, entry.key.id);
    final change = _ds.getPriceChange(product.id, entry.key.id);
    final trendColor = trend == PriceTrend.up
        ? AppColors.danger
        : trend == PriceTrend.down
            ? AppColors.success
            : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBest ? AppColors.primary.withAlpha(40) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isBest ? AppColors.primaryLight.withAlpha(120) : AppColors.divider,
            width: isBest ? 1.5 : 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isBest
                      ? AppColors.success
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    isBest ? '★' : '${rank + 1}',
                    style: GoogleFonts.outfit(
                        color: isBest ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key.name,
                        style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(entry.key.capital,
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_fmt.format(price.toInt())} Ar/${product.unit}',
                      style: GoogleFonts.outfit(
                          color: isBest ? AppColors.success : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text(
                      '${trend == PriceTrend.up ? '▲' : trend == PriceTrend.down ? '▼' : '—'} ${change.abs().toStringAsFixed(1)}%',
                      style: GoogleFonts.outfit(
                          color: trendColor, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showContactDialog(entry.key.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isBest
                        ? AppColors.primaryGradient
                        : null,
                    color: isBest ? null : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isBest
                            ? Colors.transparent
                            : AppColors.divider),
                  ),
                  child: Text('Contacter',
                      style: GoogleFonts.outfit(
                          color: isBest
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (pctAbove / 100).clamp(0.02, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        AppColors.success, AppColors.danger, pctAbove / 100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moins cher: ${_fmt.format(minPrice.toInt())} Ar',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 9)),
                Text('Plus cher: ${_fmt.format(maxPrice.toInt())} Ar',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(String regionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Contacter un vendeur',
            style: GoogleFonts.outfit(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text('Vendeurs à $regionName',
                style: GoogleFonts.outfit(
                    color: AppColors.textPrimary, fontSize: 15)),
            const SizedBox(height: 12),
            _contactCard('Jean Rakoto', '+261 34 12 345 67'),
            _contactCard('Marie Rasoa', '+261 33 98 765 43'),
            _contactCard('Paul Andry', '+261 38 55 111 22'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fermer',
                style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          )
        ],
      ),
    );
  }

  Widget _contactCard(String name, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(name[0],
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(phone,
                    style: GoogleFonts.outfit(
                        color: AppColors.accent, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.phone, color: AppColors.primaryLight, size: 18),
        ],
      ),
    );
  }
}
