import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../providers/market_provider.dart';
import '../services/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  final DataService _dataService = DataService();
  final _fmt = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _cardsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _headerAnimation =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _cardsAnimation =
        CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic);
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300),
        () => _cardsController.forward());
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketProvider>();
    final topProducts = _dataService.getTopRisingProducts();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(provider)),
            SliverToBoxAdapter(child: _buildAlertBanner(provider)),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('📈 En hausse cette semaine',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: FadeTransition(
                  opacity: _cardsAnimation,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: topProducts.length,
                    itemBuilder: (ctx, i) =>
                        _buildTrendCard(topProducts[i], i),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('🗺️ Prix par région',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildRegionPrices(provider),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('🛒 Produits du marché',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildProductGridCard(DataService.products[i]),
                  childCount: DataService.products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MarketProvider provider) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Bonjour'
        : now.hour < 18
            ? 'Bon après-midi'
            : 'Bonsoir';

    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🌾', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting,
                          style: GoogleFonts.outfit(
                              color: Colors.white70, fontSize: 14)),
                      Text('Tantsaha Market',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          color: AppColors.success, size: 8),
                      const SizedBox(width: 6),
                      Text('En direct',
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatBadge('🏝️', '22 régions'),
                const SizedBox(width: 10),
                _buildStatBadge('🌿', '20 produits'),
                const SizedBox(width: 10),
                _buildStatBadge('📊', '90j d\'historique'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(MarketProvider provider) {
    final alerts = provider.activeAlerts
        .where((a) => a.triggeredPrice != null)
        .toList();
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.dangerGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alerte Prix !',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(
                    '${alerts.first.productName} — ${alerts.first.regionName}: ${_fmt.format(alerts.first.triggeredPrice!)} Ar/kg',
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${alerts.length} alerte${alerts.length > 1 ? 's' : ''}',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget _buildTrendCard(Product product, int index) {
    final bestRegion = _dataService.getBestSellingRegion(product.id);
    final price = _dataService.getCurrentPrice(product.id, bestRegion.id);
    final change = _dataService.getPriceChange(product.id, bestRegion.id);
    final isUp = change > 0;

    final gradients = [
      [const Color(0xFF1B4332), const Color(0xFF40916C)],
      [const Color(0xFF2D3A8C), const Color(0xFF4E5FC0)],
      [const Color(0xFF6B0F1A), const Color(0xFFB91C1C)],
      [const Color(0xFF713F12), const Color(0xFFD97706)],
      [const Color(0xFF134E4A), const Color(0xFF0F766E)],
    ];
    final grad = gradients[index % gradients.length];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: grad,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: grad[0].withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(product.icon, style: const TextStyle(fontSize: 28)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text(bestRegion.name,
                  style: GoogleFonts.outfit(
                      color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_fmt.format(price)} Ar',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUp
                          ? AppColors.danger.withAlpha(180)
                          : AppColors.success.withAlpha(180),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        '${isUp ? '▲' : '▼'} ${change.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 10)),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionPrices(MarketProvider provider) {
    final regions = _dataService.getPricesByRegion('riz', ascending: false);
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: regions.length.clamp(0, 8),
        itemBuilder: (ctx, i) {
          final entry = regions[i];
          final isTop = i == 0;
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isTop ? AppColors.goldGradient : null,
              color: isTop ? null : AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isTop
                      ? Colors.transparent
                      : AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isTop)
                      const Text('🥇', style: TextStyle(fontSize: 14))
                    else
                      Text('${i + 1}.',
                          style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(entry.key.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                              color: isTop
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Text('🌾 Riz',
                    style: GoogleFonts.outfit(
                        color: isTop
                            ? AppColors.primary.withAlpha(180)
                            : AppColors.textSecondary,
                        fontSize: 11)),
                Text('${_fmt.format(entry.value)} Ar',
                    style: GoogleFonts.outfit(
                        color: isTop ? AppColors.primary : AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGridCard(Product product) {
    final avgPrice = _dataService.getNationalAveragePrice(product.id);
    // Get the best change across regions
    double bestChange = 0;
    for (final r in DataService.regions) {
      final c = _dataService.getPriceChange(product.id, r.id);
      if (c.abs() > bestChange.abs()) bestChange = c;
    }
    final isUp = bestChange > 0;

    return GestureDetector(
      onTap: () {
        context.read<MarketProvider>().selectProduct(product.id);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight.withAlpha(50), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.icon, style: const TextStyle(fontSize: 24)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUp
                        ? AppColors.danger.withAlpha(40)
                        : AppColors.success.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      '${isUp ? '▲' : '▼'} ${bestChange.abs().toStringAsFixed(1)}%',
                      style: GoogleFonts.outfit(
                          color: isUp ? AppColors.danger : AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Spacer(),
            Text(product.name,
                style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text('${_fmt.format(avgPrice)} Ar/${product.unit}',
                style: GoogleFonts.outfit(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
