import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login(String credentials, String password) async {
    // Simuler un appel réseau
    await Future.delayed(const Duration(seconds: 2));
    
    // Identifiants factices pour le test
    if (password == '123456') { 
      return UserModel(
        id: '1',
        nom: 'Utilisateur Professionnel',
        email: credentials.contains('@') ? credentials : 'admin@tantsaha.com',
      );
    } else {
      throw Exception('Identifiants incorrects. Utilisez le mot de passe "123456".');
    }
  }
}
