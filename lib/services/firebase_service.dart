import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/deposit_model.dart';
import '../../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getUserByEmail(String email) async {
    final clientsCollection = FirebaseFirestore.instance.collection('clients');
    final distributorsCollection =
        FirebaseFirestore.instance.collection('distributors');

    try {
      final querySnapshot =
          await clientsCollection.where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(querySnapshot.docs.first.data());
      }

      final distributorSnapshot =
          await distributorsCollection.where('email', isEqualTo: email).get();
      if (distributorSnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(distributorSnapshot.docs.first.data());
      }

      // Si aucun utilisateur n'est trouvé, on peut lancer une exception
      throw Exception('Aucun utilisateur trouvé avec cet email');
    } catch (e) {
      // Gérer les erreurs liées à la connexion à Firestore
      if (e is FirebaseException) {
        print('Erreur Firebase: ${e.message}');
      } else {
        print('Erreur générale: $e');
      }
    }
    return null;
  }

  // Ajouter une transactionFuture<String> getNextSequentialId(String collectionName) async {
  Future<String> getNextSequentialId(String collectionName) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Récupérer le dernier ID et l'incrémenter
      final lastId = int.parse(snapshot.docs.first['id'] ?? '0');
      return (lastId + 1).toString().padLeft(6, '0');
    }

    // Commencer à 1 si la collection est vide
    return '1';
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

  // Méthode pour enregistrer un nouvel utilisateur
  Future<UserModel?> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    String? photoUrl,
    required String cni,
    required String role,
    double initialBalance = 0.0,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer l'ID de l'utilisateur
      String userId = userCredential.user!.uid;

      // Créer un modèle d'utilisateur
      UserModel userModel = UserModel(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        photo: photoUrl,
        cni: cni,
        role: role,
        balance: initialBalance, // Ajouter le solde initial
      );

      // Enregistrer les données de l'utilisateur dans Firestore
      await _firestore.collection('users').doc(userId).set(userModel.toMap());

      return userModel; // Retourner le modèle d'utilisateur
    } catch (e) {
      throw Exception("Erreur lors de l'inscription : $e");
    }
  }

  /// Obtenir le prochain ID séquentiel pour une collection
  Future<int> getNextId(String collectionName) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final lastId = int.parse(snapshot.docs.first['id']);
      return lastId + 1;
    }

    return 1; // Commencer à 1 si la collection est vide
  }

  // Ajouter un utilisateur à une collection spécifique
  Future<void> addUser(String collectionName, UserModel user) async {
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

  // Récupérer un utilisateur par son ID Firebase
  Future<UserModel?> getUserById(String firebaseUid) async {
    try {
      // Vérifier d'abord dans la collection des clients
      var clientDoc = await _firestore
          .collection('clients')
          .where('id', isEqualTo: firebaseUid)
          .get();

      if (clientDoc.docs.isNotEmpty) {
        return UserModel.fromJson(clientDoc.docs.first.data());
      }

      // Si pas trouvé, vérifier dans la collection des distributeurs
      var distributorDoc = await _firestore
          .collection('distributors')
          .where('id', isEqualTo: firebaseUid)
          .get();

      if (distributorDoc.docs.isNotEmpty) {
        return UserModel.fromJson(distributorDoc.docs.first.data());
      }

      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        print("Aucun utilisateur connecté.");
        return null;
      }

      // Vérifiez dans 'clients'
      final client = await getUserById(firebaseUser.uid);
      if (client != null) {
        return client;
      }

      // Vérifiez dans 'distributors'
      final distributor = await getUserById(firebaseUser.uid);
      if (distributor != null) {
        return distributor;
      }

      print("Aucun utilisateur trouvé pour l'ID : ${firebaseUser.uid}");
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur connecté : $e");
      return null;
    }
  }

  Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des transactions : $e");
      return [];
    }
  }

  // Ajouter un utilisateur à une collection spécifique
  Future<void> addUserToSpecificCollection({
    required String role,
    required Map<String, dynamic> userData,
  }) async {
    final collectionName =
        role.toLowerCase() == 'client' ? 'clients' : 'distributors';

    try {
      await _firestore.collection(collectionName).doc(userData['id']).set({
        ...userData,
        'etat': 'actif',
        'balance': userData['balance'] ?? 0.0,
        'transactions': [],
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur: $e');
      throw e;
    }
  }

  Future<UserModel?> getUserByAccountNumber(String accountNumber) async {
    try {
      // Rechercher dans la collection des clients
      final clientSnapshot = await _firestore
          .collection('clients')
          .where('accountNumber', isEqualTo: accountNumber)
          .get();

      if (clientSnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(clientSnapshot.docs.first.data());
      }

      // Si non trouvé dans clients, rechercher dans distributeurs
      final distributorSnapshot = await _firestore
          .collection('distributors')
          .where('accountNumber', isEqualTo: accountNumber)
          .get();

      if (distributorSnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(distributorSnapshot.docs.first.data());
      }

      return null;
    } catch (e) {
      print('Erreur lors de la recherche de l\'utilisateur: $e');
      return null;
    }
  }

  Future<void> updateUserBalance(String userId, double newBalance) async {
    try {
      // Vérifier si l'utilisateur existe dans la collection clients
      var clientDoc = await _firestore.collection('clients').doc(userId).get();
      if (clientDoc.exists) {
        await _firestore.collection('clients').doc(userId).update({
          'balance': newBalance,
        });
        return;
      }

      // Vérifier si l'utilisateur existe dans la collection distributeurs
      var distributorDoc =
          await _firestore.collection('distributors').doc(userId).get();
      if (distributorDoc.exists) {
        await _firestore.collection('distributors').doc(userId).update({
          'balance': newBalance,
        });
        return;
      }

      throw Exception('Utilisateur non trouvé');
    } catch (e) {
      print('Erreur lors de la mise à jour du solde: $e');
      throw e;
    }
  }
}
