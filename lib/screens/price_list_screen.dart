import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../providers/market_provider.dart';
import '../services/data_service.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  String _search = '';
  String _sortBy = 'name'; // name | price_asc | price_desc | change
  final _fmt = NumberFormat('#,###', 'fr_FR');
  final DataService _ds = DataService();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketProvider>();

    List<Product> products = provider.filteredProducts
        .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    if (_sortBy == 'price_asc' || _sortBy == 'price_desc') {
      final regionId = provider.selectedRegionId;
      products.sort((a, b) {
        final pa = _ds.getCurrentPrice(a.id, regionId);
        final pb = _ds.getCurrentPrice(b.id, regionId);
        return _sortBy == 'price_asc'
            ? pa.compareTo(pb)
            : pb.compareTo(pa);
      });
    } else if (_sortBy == 'change') {
      final regionId = provider.selectedRegionId;
      products.sort((a, b) {
        final ca = _ds.getPriceChange(a.id, regionId).abs();
        final cb = _ds.getPriceChange(b.id, regionId).abs();
        return cb.compareTo(ca);
      });
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(provider),
            _buildSearchAndSort(),
            _buildCategoryChips(provider),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: products.length,
                itemBuilder: (ctx, i) =>
                    _buildProductRow(products[i], provider.selectedRegionId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MarketProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Text('🛒', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Prix du Marché',
                style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButton<String>(
              value: provider.selectedRegionId,
              underline: const SizedBox.shrink(),
              dropdownColor: AppColors.surface,
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary, fontSize: 12),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary, size: 16),
              items: DataService.regions
                  .map((r) => DropdownMenuItem(
                      value: r.id, child: Text(r.name)))
                  .toList(),
              onChanged: (v) =>
                  context.read<MarketProvider>().selectRegion(v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.outfit(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  hintStyle: GoogleFonts.outfit(
                      color: AppColors.textSecondary, fontSize: 13),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox.shrink(),
              dropdownColor: AppColors.surface,
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary, fontSize: 12),
              icon: const Icon(Icons.sort, color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Nom')),
                DropdownMenuItem(
                    value: 'price_asc', child: Text('Prix ↑')),
                DropdownMenuItem(
                    value: 'price_desc', child: Text('Prix ↓')),
                DropdownMenuItem(
                    value: 'change', child: Text('Variation')),
              ],
              onChanged: (v) => setState(() => _sortBy = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(MarketProvider provider) {
    final categories = ['Tous', 'Céréales', 'Légumes', 'Fruits', 'Légumineuses', 'Épices'];
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final selected = provider.selectedCategory == cat;
          return GestureDetector(
            onTap: () => provider.selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected ? null : AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? Colors.transparent : AppColors.divider),
              ),
              child: Text(cat,
                  style: GoogleFonts.outfit(
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductRow(Product product, String regionId) {
    final price = _ds.getCurrentPrice(product.id, regionId);
    final change = _ds.getPriceChange(product.id, regionId);
    final trend = _ds.getTrend(product.id, regionId);
    final best = _ds.getBestSellingRegion(product.id);
    final bestPrice = _ds.getCurrentPrice(product.id, best.id);

    final trendColor = trend == PriceTrend.up
        ? AppColors.danger
        : trend == PriceTrend.down
            ? AppColors.success
            : AppColors.textSecondary;
    final trendIcon = trend == PriceTrend.up
        ? '▲'
        : trend == PriceTrend.down
            ? '▼'
            : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(product.icon,
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text(product.category,
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Meilleur: ${best.name}',
                        style: GoogleFonts.outfit(
                            color: AppColors.accent, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_fmt.format(price)} Ar',
                  style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Row(
                children: [
                  Text('$trendIcon ${change.abs().toStringAsFixed(1)}%',
                      style: GoogleFonts.outfit(
                          color: trendColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  if (bestPrice > price) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(40),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                          '+${(((bestPrice - price) / price) * 100).toStringAsFixed(0)}% ailleurs',
                          style: GoogleFonts.outfit(
                              color: AppColors.accent, fontSize: 9)),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
