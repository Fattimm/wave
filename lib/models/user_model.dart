import '../models/transaction_model.dart';

class UserModel {
  String id;
  String firstName;
  String lastName;
  String phone;
  String email;
  String password;
  String role;
  String cni;
  String? photo;
  double balance;
  String etat;
  List<TransactionModel> transactions;

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
    this.transactions = const [],
  });

  // Conversion de Map à UserModel avec gestion correcte des transactions
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      phone: data['phone'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? 'client',
      cni: data['cni'] ?? '',
      photo: data['photo'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      etat: data['etat'] ?? 'actif',
      transactions: (data['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Conversion de UserModel à Map avec sérialisation correcte des transactions
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'role': role,
      'cni': cni,
      'photo': photo,
      'balance': balance,
      'etat': etat,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? 'client',
        cni: json['cni'] ?? '',
        photo: json['photo'],
        balance: (json['balance'] ?? 0.0).toDouble(),
        etat: json['etat'] ?? 'actif',
        transactions: (json['transactions'] as List<dynamic>?)
                ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Erreur lors de la désérialisation de UserModel: $e');
      print('JSON reçu: $json');
      rethrow;
    }
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
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? password,
    String? role,
    String? cni,
    String? photo,
    double? balance,
    String? etat,
    List<TransactionModel>? transactions,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      cni: cni ?? this.cni,
      photo: photo ?? this.photo,
      balance: balance ?? this.balance,
      etat: etat ?? this.etat,
      transactions: transactions ?? List.from(this.transactions),
    );
  }

  bool validate() {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        cni.isEmpty) {
      return false;
    }
    return true;
  }

  double getBalance() {
    return balance;
  }

  // Méthodes de transaction améliorées
  Future<TransactionModel> createDeposit({
    required String recipientPhone,
    required double amount,
  }) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.depot,
      senderId: this.id,
      senderPhone: this.phone,
      senderRole: this.role,
      recipientId: '',  // À remplir avec l'ID du destinataire
      recipientPhone: recipientPhone,
      recipientRole: 'client',
      amount: amount,
      date: DateTime.now(),
      initiatorPhone: this.phone,
      initiatorRole: UserRole.distributeur,
      description: 'Dépôt effectué par distributeur',
    );
    return transaction;
  }

  Future<TransactionModel> createWithdrawal({
    required String recipientPhone,
    required double amount,
  }) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.retrait,
      senderId: this.id,
      senderPhone: this.phone,
      senderRole: this.role,
      recipientId: '',  // À remplir avec l'ID du destinataire
      recipientPhone: recipientPhone,
      recipientRole: 'client',
      amount: amount,
      date: DateTime.now(),
      initiatorPhone: this.phone,
      initiatorRole: UserRole.distributeur,
      description: 'Retrait effectué par distributeur',
    );
    return transaction;
  }

  Future<TransactionModel> createTransfer({
    required String recipientPhone,
    required double amount,
    String? description,
  }) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.transfert,
      senderId: this.id,
      senderPhone: this.phone,
      senderRole: this.role,
      recipientId: '',  // À remplir avec l'ID du destinataire
      recipientPhone: recipientPhone,
      recipientRole: 'client',
      amount: amount,
      date: DateTime.now(),
      initiatorPhone: this.phone,
      initiatorRole: UserRole.client,
      description: description ?? 'Transfert d\'argent',
    );
    return transaction;
  }
}