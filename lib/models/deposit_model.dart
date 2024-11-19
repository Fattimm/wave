class DepositModel {
  final String id; // Identifiant unique du dépôt
  final String distributorId; // ID du distributeur effectuant le dépôt
  final String clientId; // ID du client recevant le dépôt
  final double amount; // Montant déposé
  final String method; // Méthode : par téléphone, scan QR, etc.
  final String date; // Date au format ISO (YYYY-MM-DD HH:mm:ss)

  DepositModel({
    required this.id,
    required this.distributorId,
    required this.clientId,
    required this.amount,
    required this.method,
    required this.date,
  });

  // Convertir JSON en DepositModel
  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'],
      distributorId: json['distributorId'],
      clientId: json['clientId'],
      amount: (json['amount'] as num).toDouble(),
      method: json['method'],
      date: json['date'],
    );
  }

  // Convertir DepositModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distributorId': distributorId,
      'clientId': clientId,
      'amount': amount,
      'method': method,
      'date': date,
    };
  }
}
