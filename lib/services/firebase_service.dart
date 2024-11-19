import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/deposit_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer un utilisateur par email
  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  // Ajouter un dépôt
  Future<void> addDeposit(DepositModel deposit) async {
    await _firestore
        .collection('deposits')
        .doc(deposit.id)
        .set(deposit.toJson());
  }

  // Récupérer les dépôts d'un distributeur
  Future<List<DepositModel>> getDistributorDeposits(
      String distributorId) async {
    final snapshot = await _firestore
        .collection('deposits')
        .where('distributorId', isEqualTo: distributorId)
        .get();
    return snapshot.docs
        .map((doc) => DepositModel.fromJson(doc.data()))
        .toList();
  }

  Future<UserModel?> createUser(
      String firstName,
      String lastName,
      String phone,
      String email,
      String password,
      String photo,
      String role,
      String cni) async {
    try {
      // Créer l'utilisateur avec Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      // Si l'utilisateur est créé, ajoutez-le à Firestore
      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          email: email,
          password: password, // Note : Ne pas stocker le mot de passe en clair
          photo: photo,
          role: role,
          cni: cni,
        );

        // Enregistrer l'utilisateur dans Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());
        return newUser; // Retourner l'utilisateur créé
      }
    } catch (e) {
      print("Erreur lors de la création de l'utilisateur: $e");
      return null; // En cas d'erreur, retourner null
    }
    return null; // Retourner null si l'utilisateur n'est pas créé
  }

  // Ajouter un utilisateur à Firestore
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  // Obtenir le prochain ID séquentiel
  Future<int> getNextId(String collectionName) async {
    final snapshot =
        await _firestore.collection(collectionName).orderBy('id').get();
    if (snapshot.docs.isNotEmpty) {
      // Récupère le dernier ID et l'incrémente
      final lastId = int.parse(snapshot.docs.last['id']);
      return lastId + 1;
    } else {
      // Si la collection est vide, commence à 1
      return 1;
    }
  }

  // Ajouter un utilisateur à une collection spécifique
  Future<void> addUserToCollection(
      String collectionName, UserModel user) async {
    await _firestore.collection(collectionName).doc(user.id).set({
      ...user.toJson(),
      'etat': 'actif', // État par défaut
    });
  }

  // Récupérer un utilisateur par numéro de téléphone
  Future<UserModel?> getUserByPhone(String phone) async {
    // Vérifier d'abord dans la collection des clients
    final clientSnapshot = await _firestore
        .collection('clients')
        .where('phone', isEqualTo: phone)
        .get();

    if (clientSnapshot.docs.isNotEmpty) {
      return UserModel.fromJson(clientSnapshot.docs.first.data());
    }

    // Si non trouvé, vérifier dans la collection des distributeurs
    final distributorSnapshot = await _firestore
        .collection('distributors')
        .where('phone', isEqualTo: phone)
        .get();

    if (distributorSnapshot.docs.isNotEmpty) {
      return UserModel.fromJson(distributorSnapshot.docs.first.data());
    }

    return null; // Aucun utilisateur trouvé dans les deux collections
  }

  // Récupérer les transactions d'un utilisateur
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  // Ajouter un retrait
  Future<void> addWithdrawal(String clientId, double amount) async {
    // Implémentez la logique pour ajouter un retrait
    final withdrawal = {
      'clientId': clientId,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };
    await _firestore.collection('withdrawals').add(withdrawal);
  }

  // Ajouter un déplafonnement
  Future<void> addLimitIncrease(String clientId, double amount) async {
    // Implémentez la logique pour ajouter un déplafonnement
    final limitIncrease = {
      'clientId': clientId,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };
    await _firestore.collection('limit_increases').add(limitIncrease);
  }

  // Ajouter une transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  // Récupérer les transactions d'un distributeur
  Future<List<TransactionModel>> getDistributorTransactions(
      String distributorId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('senderId', isEqualTo: distributorId)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  // Récupérer les transactions d'un client
  Future<List<TransactionModel>> getClientTransactions(String clientId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('recipientId', isEqualTo: clientId)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }
}
