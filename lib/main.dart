import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'constants/theme.dart';
import 'providers/market_provider.dart';
import 'screens/home_screen.dart';
import 'screens/price_list_screen.dart';
import 'screens/map_screen.dart';
import 'screens/history_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/buyer_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    riverpod.ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MarketProvider()),
        ],
        child: const TantsahaMarketApp(),
      ),
    ),
  );
}

class TantsahaMarketApp extends StatelessWidget {
  const TantsahaMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tantsaha Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}

class MainShell extends riverpod.ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  riverpod.ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends riverpod.ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    _NavItem(icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt, label: 'Prix'),
    _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Carte'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Historique'),
    _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alertes'),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    PriceListScreen(),
    MapScreen(),
    HistoryScreen(),
    AlertsScreen(),
  ];

  void _openBuyerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuyerScreen()),
    );
  }

  void _openAiScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketProvider>();
    final alertCount = provider.unreadAlertsCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNav(alertCount),
      floatingActionButton: _currentIndex == 0
          ? _buildFab()
          : null,
    );
  }

  Widget _buildBottomNav(int alertCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final selected = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryLight.withAlpha(40)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                selected ? item.activeIcon : item.icon,
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                            ),
                            if (i == 4 && alertCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$alertCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.outfit(
                            color: selected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'ai',
          backgroundColor: AppColors.accent,
          onPressed: _openAiScreen,
          child: const Text('🤖', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'buyer',
          backgroundColor: AppColors.primaryLight,
          onPressed: _openBuyerScreen,
          child: const Text('🏢', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('🌾', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tantsaha Market',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text('v1.0.0 — Madagascar',
                          style: GoogleFonts.outfit(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.home, 'Accueil', () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            }),
            _drawerItem(Icons.list_alt, 'Prix du Marché', () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            }),
            _drawerItem(Icons.map, 'Carte des Prix', () {
              setState(() => _currentIndex = 2);
              Navigator.pop(context);
            }),
            _drawerItem(Icons.bar_chart, 'Historique', () {
              setState(() => _currentIndex = 3);
              Navigator.pop(context);
            }),
            _drawerItem(Icons.notifications, 'Alertes', () {
              setState(() => _currentIndex = 4);
              Navigator.pop(context);
            }),
            const Divider(color: AppColors.divider),
            _drawerItem(Icons.business, 'Espace Grossistes', () {
              Navigator.pop(context);
              _openBuyerScreen();
            }),
            _drawerItem(Icons.psychology, 'Prédiction des prix', () {
              Navigator.pop(context);
              _openAiScreen();
            }),
            const Spacer(),
            const Divider(color: AppColors.divider),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
              title: Text('Déconnexion',
                  style: GoogleFonts.outfit(
                      color: AppColors.danger,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              horizontalTitleGap: 8,
              dense: true,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '🌾 Tantsaha Market — Pour les paysans malgaches',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryLight, size: 22),
      title: Text(label,
          style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
      horizontalTitleGap: 8,
      dense: true,
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}
