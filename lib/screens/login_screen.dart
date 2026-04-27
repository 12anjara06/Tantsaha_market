import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../main.dart'; // Pour MainShell
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscureText = true;

  void _login() {
    FocusScope.of(context).unfocus(); // Cacher le clavier
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    
    ref.read(authProvider.notifier).login(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.danger),
        );
      }
      if (next.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
         decoration: const BoxDecoration(gradient: AppColors.bgGradient),
         child: SafeArea(
           child: Center(
             child: SingleChildScrollView(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       gradient: AppColors.primaryGradient,
                       shape: BoxShape.circle,
                       boxShadow: [
                         BoxShadow(
                           color: AppColors.primaryLight.withAlpha(50),
                           blurRadius: 30,
                           spreadRadius: 10,
                         ),
                       ],
                     ),
                     child: const Text('🌾', style: TextStyle(fontSize: 54)),
                   ),
                   const SizedBox(height: 24),
                   Text(
                     'Tantsaha Market',
                     style: GoogleFonts.outfit(
                       color: AppColors.textPrimary,
                       fontSize: 32,
                       fontWeight: FontWeight.w800,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     'Connexion Professionnelle',
                     style: GoogleFonts.outfit(
                       color: AppColors.primaryLight,
                       fontSize: 16,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   const SizedBox(height: 48),
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: AppColors.cardBg.withAlpha(200),
                       borderRadius: BorderRadius.circular(24),
                       border: Border.all(color: AppColors.divider, width: 1.5),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withAlpha(30),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                         ),
                       ],
                     ),
                     child: Column(
                       children: [
                         _buildTextField(
                           controller: _emailCtrl,
                           icon: Icons.person_outline,
                           hint: 'Email ou Téléphone',
                         ),
                         const SizedBox(height: 16),
                         _buildTextField(
                           controller: _passCtrl,
                           icon: Icons.lock_outline,
                           hint: 'Mot de passe (tester: 123456)',
                           isPassword: true,
                         ),
                         const SizedBox(height: 16),
                         Align(
                           alignment: Alignment.centerRight,
                           child: Text(
                             'Mot de passe oublié ?',
                             style: GoogleFonts.outfit(
                               color: AppColors.primaryLight,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ),
                         const SizedBox(height: 24),
                         SizedBox(
                           width: double.infinity,
                           height: 52,
                           child: ElevatedButton(
                             onPressed: authState.isLoading ? null : _login,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                               padding: EdgeInsets.zero,
                               shadowColor: Colors.transparent,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(16),
                               ),
                             ),
                             child: Ink(
                               decoration: BoxDecoration(
                                 gradient: AppColors.goldGradient,
                                 borderRadius: BorderRadius.circular(16),
                                 boxShadow: [
                                   BoxShadow(
                                     color: AppColors.accent.withAlpha(50),
                                     blurRadius: 10,
                                     offset: const Offset(0, 4),
                                   ),
                                 ],
                               ),
                               child: Container(
                                 alignment: Alignment.center,
                                 child: authState.isLoading 
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                      )
                                    : Text(
                                        'Se Connecter',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.primary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 32),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                         "Pas encore de compte ? ",
                         style: GoogleFonts.outfit(color: AppColors.textSecondary),
                       ),
                       TextButton(
                         style: TextButton.styleFrom(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           minimumSize: Size.zero,
                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                         onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (_) => const RegisterScreen()),
                           );
                         },
                         child: Text(
                           "Rejoindre",
                           style: GoogleFonts.outfit(
                             color: AppColors.primaryLighter,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
           ),
         ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        style: GoogleFonts.outfit(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primaryLight),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary.withAlpha(150)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
