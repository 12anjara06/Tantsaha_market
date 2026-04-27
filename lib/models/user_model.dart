class UserModel {
  final String id;
  final String nom;
  final String email;

  UserModel({required this.id, required this.nom, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      email: json['email'] as String,
    );
  }
}
