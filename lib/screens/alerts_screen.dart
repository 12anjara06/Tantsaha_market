import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../providers/market_provider.dart';
import '../services/data_service.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  final _fmt = NumberFormat('#,###', 'fr_FR');

  void _goToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showAddAlertDialog(BuildContext context) {
    String selectedProduct = DataService.products.first.id;
    String selectedRegion = DataService.regions.first.id;
    bool isAbove = true;
    double threshold = 0;
    final controller = TextEditingController();
    final ds = DataService();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Nouvelle Alerte',
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogDropdown<String>(
                  label: 'Produit',
                  value: selectedProduct,
                  items: DataService.products
                      .map((p) => DropdownMenuItem(
                          value: p.id, child: Text('${p.icon} ${p.name}')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedProduct = v!),
                ),
                const SizedBox(height: 12),
                _dialogDropdown<String>(
                  label: 'Région',
                  value: selectedRegion,
                  items: DataService.regions
                      .map((r) =>
                          DropdownMenuItem(value: r.id, child: Text(r.name)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedRegion = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => isAbove = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isAbove
                                ? AppColors.danger.withAlpha(60)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isAbove
                                    ? AppColors.danger
                                    : AppColors.divider),
                          ),
                          child: Center(
                            child: Text('▲ Au-dessus',
                                style: GoogleFonts.outfit(
                                    color: isAbove
                                        ? AppColors.danger
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => isAbove = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isAbove
                                ? AppColors.success.withAlpha(60)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: !isAbove
                                    ? AppColors.success
                                    : AppColors.divider),
                          ),
                          child: Center(
                            child: Text('▼ En dessous',
                                style: GoogleFonts.outfit(
                                    color: !isAbove
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Builder(builder: (ctx) {
                  final currentPrice =
                      ds.getCurrentPrice(selectedProduct, selectedRegion);
                  if (controller.text.isEmpty) {
                    controller.text = currentPrice.toInt().toString();
                  }
                  return TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                    onChanged: (v) => threshold = double.tryParse(v) ?? 0,
                    decoration: InputDecoration(
                      labelText: 'Seuil (Ar/kg)',
                      labelStyle:
                          GoogleFonts.outfit(color: AppColors.textSecondary),
                      suffixText: 'Ar',
                      suffixStyle: GoogleFonts.outfit(color: AppColors.accent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.primaryLight),
                      ),
                      helperText:
                          'Prix actuel: ${_fmt.format(currentPrice.toInt())} Ar',
                      helperStyle: GoogleFonts.outfit(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final t = double.tryParse(controller.text) ?? 0;
                if (t > 0) {
                  context.read<MarketProvider>().addAlert(
                        productId: selectedProduct,
                        regionId: selectedRegion,
                        threshold: t,
                        isAbove: isAbove,
                      );
                }
                Navigator.pop(ctx);
              },
              child: Text('Créer',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketProvider>();
    final alerts = provider.alerts;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(alerts, context),
            Expanded(
              child: alerts.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: alerts.length,
                      itemBuilder: (ctx, i) =>
                          _buildAlertCard(alerts[i], provider),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<Alert> alerts, BuildContext context) {
    final triggered = alerts.where((a) => a.triggeredPrice != null).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goToHome,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          const Text('🔔', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alertes Prix',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                if (triggered > 0)
                  Text(
                      '$triggered alerte${triggered > 1 ? 's' : ''} déclenchée${triggered > 1 ? 's' : ''}',
                      style: GoogleFonts.outfit(
                          color: AppColors.danger, fontSize: 12)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showAddAlertDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppColors.danger, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert, MarketProvider provider) {
    final isTriggered = alert.triggeredPrice != null;
    final color = alert.isAbove ? AppColors.danger : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isTriggered ? color.withAlpha(120) : AppColors.divider,
            width: isTriggered ? 1.5 : 1),
        boxShadow: isTriggered
            ? [
                BoxShadow(
                    color: color.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(isTriggered ? '🔔' : '🔕',
                style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${alert.productName} — ${alert.regionName}',
                    style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(
                    '${alert.isAbove ? '▲ Au-dessus de' : '▼ En dessous de'} ${_fmt.format(alert.threshold.toInt())} Ar',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 12)),
                if (isTriggered)
                  Text(
                      '✅ Déclenché à ${_fmt.format(alert.triggeredPrice!.toInt())} Ar',
                      style: GoogleFonts.outfit(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.removeAlert(alert.id),
            icon: const Icon(Icons.close,
                color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Aucune alerte configurée',
              style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Appuyez sur + pour créer une alerte',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
