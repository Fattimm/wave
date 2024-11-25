import 'package:get/get.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';


abstract class BaseController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();
  
  var isLoading = false.obs;
  var transactions = <TransactionModel>[].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool balanceVisible = false.obs;

  // Charger l'utilisateur connecté
  Future<void> loadCurrentUser() async {
    try {
      isLoading.value = true;
      currentUser.value = await firebaseService.getCurrentUser();
      if (currentUser.value != null) {
        await fetchTransactions(currentUser.value!.id);
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Méthodes communes pour rechercher des utilisateurs
  Future<UserModel?> getUserByAccountNumber(String accountNumber) async {
    try {
      return await firebaseService.getUserByAccountNumber(accountNumber);
    } catch (e) {
      print("Erreur lors de la recherche de l'utilisateur: $e");
      throw Exception("Utilisateur non trouvé");
    }
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      return await firebaseService.getUserByPhone(phone);
    } catch (e) {
      print("Erreur lors de la recherche de l'utilisateur: $e");
      throw Exception("Utilisateur non trouvé");
    }
  }

  // Méthode commune pour récupérer toutes les transactions d'un utilisateur
  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    try {
      return await firebaseService.getUserTransactions(userId);
    } catch (e) {
      print("Erreur lors de la récupération des transactions: $e");
      return [];
    }
  }

  // Méthode à implémenter dans les sous-classes selon le type d'utilisateur
  Future<void> fetchTransactions(String userId);

  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
  }

  // Méthode commune pour mettre à jour le solde
  Future<void> updateUserBalance(String userId, double newBalance) async {
    try {
      await firebaseService.updateUserBalance(userId, newBalance);
      currentUser.update((user) {
        if (user != null) {
          user.balance = newBalance;
        }
      });
    } catch (e) {
      print("Erreur lors de la mise à jour du solde: $e");
      throw Exception("Échec de la mise à jour du solde");
    }
  }
}
