import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text('🌾', style: TextStyle(fontSize: 54)),
                  const SizedBox(height: 12),
                  Text(
                    'Rejoignez-nous',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                        _buildTextField(controller: _nameCtrl, icon: Icons.person_outline, hint: 'Nom Complet'),
                        const SizedBox(height: 16),
                        _buildTextField(controller: _emailCtrl, icon: Icons.email_outlined, hint: 'Email ou Téléphone'),
                        const SizedBox(height: 16),
                        _buildTextField(controller: _passCtrl, icon: Icons.lock_outline, hint: 'Mot de passe', isPassword: true),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Inscription réussie ! Veuillez utiliser ces identifiants pour vous connecter.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              Navigator.pop(context); // Retour automatique vers la page de login
                            },
                            style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                               padding: EdgeInsets.zero,
                               shadowColor: Colors.transparent,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient, 
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withAlpha(50),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text('S\'inscrire', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              )
                            )
                          )
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Retour à l\'écran de connexion',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false}) {
     return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        style: GoogleFonts.outfit(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primaryLight),
          suffixIcon: isPassword 
            ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary), onPressed: () => setState(() => _obscureText = !_obscureText)) 
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
