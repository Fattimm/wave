import 'package:get/get.dart';
import '../../models/transaction_model.dart';
import '../../services/firebase_service.dart';
import 'auth_controller.dart';
import '../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class ClientController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs; 
  var transactions = <TransactionModel>[].obs; 
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool balanceVisible = false.obs;


 @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  @override
  Future<void> fetchTransactions(String userId) async {
    try {
      transactions.value = await firebaseService.getClientTransactions(userId);
    } catch (e) {
      print("Erreur lors de la récupération des transactions: $e");
    }
  }

  
  Future<void> loadCurrentUser() async {
    try {
      final user = await firebaseService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    }
  }

  Future<void> loadTransactions() async {
    try {
      if (currentUser.value != null) {
        final userTransactions = await firebaseService.getClientTransactions(currentUser.value!.id);
        transactions.assignAll(userTransactions);
      }
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    }
  }

  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
  }

  Future<void> registerClient(
    String firstName,
    String lastName,
    String phone,
    String email,
    String password,
    String? photoUrl,
    String cni,
    String role,
  ) async {
    try {
      UserModel? newUser = await firebaseService.registerUser(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        photoUrl: photoUrl,
        cni: cni,
        role: role,
      );

      if (newUser != null) {
        Get.snackbar("Succès", "Compte créé avec succès !");
      }
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    }
  }
}
