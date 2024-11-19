class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String role;
  final String cni;
  final String? photo;
  final double balance;
  final String etat;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    required this.cni,
    this.photo,
    this.balance = 0.0,
    this.etat = 'actif',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      cni: json['cni'],
      photo: json['photo'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      etat: json['etat'] ?? 'actif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'password': password,
      'role': role,
      'cni': cni,
      'photo': photo,
      'balance': balance,
      'etat': etat,
    };
  }

  bool validate() {
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty) {
      return false;
    }
    // Ajouter d'autres validations spécifiques ici, par exemple pour un format de téléphone ou d'email.
    return true;
  }
}
