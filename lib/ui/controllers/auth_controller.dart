import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class AuthController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var isLoading = false.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  var balance = 0.0.obs;
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeAuth();
  }

  Future<void> initializeAuth() async {
    try {
      isLoading.value = true;

      // Vérifie d'abord les SharedPreferences
      await loadCurrentUser();

      // Si aucun utilisateur dans SharedPreferences, vérifie Firebase
      if (currentUser.value == null) {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          await _loadUserFromFirebase(firebaseUser.uid);
        }
      }

      // Configure l'écouteur de changement d'état
      ever(currentUser, _handleAuthStateChange);

      isInitialized.value = true;
    } catch (e) {
      print("Erreur d'initialisation: $e");
      Get.snackbar('Erreur', 'Erreur lors de l\'initialisation de la session',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserFromFirebase(String uid) async {
    try {
      // Vérifie d'abord dans la collection distributors
      var userDoc = await FirebaseFirestore.instance
          .collection('distributors')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        // Si non trouvé, vérifie dans la collection clients
        userDoc = await FirebaseFirestore.instance
            .collection('clients')
            .doc(uid)
            .get();
      }

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Vérifiez et traitez les transactions ici
        if (userData['transactions'] != null &&
            (userData['transactions'] as List<dynamic>).isNotEmpty) {
          print("Transactions disponibles: ${userData['transactions']}");
        } else {
          print("Aucune transaction disponible pour cet utilisateur.");
        }

        currentUser.value = UserModel.fromJson(userData);
        await saveCurrentUser(currentUser.value!);

        // if (userDoc.exists) {
        //   final userData = userDoc.data() as Map<String, dynamic>;

        //   currentUser.value = UserModel.fromJson(userData);
        //   await saveCurrentUser(currentUser.value!);
      }
    } catch (e) {
      print("Erreur lors du chargement de l'utilisateur depuis Firebase: $e");
      throw e;
    }
  }

  void _handleAuthStateChange(UserModel? user) {
    if (user != null && isInitialized.value) {
      balance.value = user.balance;
      _redirectUser(user.role);
    }
  }

  // Future<void> loadCurrentUser() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userData = prefs.getString('currentUser');

  //     if (userData != null) {
  //       final userJson = jsonDecode(userData);
  //       currentUser.value = UserModel.fromJson(userJson);
  //     }
  //   } catch (e) {
  //     print("Erreur lors du chargement des préférences: $e");
  //   }
  // }

  Future<void> loadCurrentUser() async {
    try {
      isLoading.value = true;
      final user = await firebaseService.getCurrentUser();
      if (user != null) {
        // Vérifiez et traitez les transactions ici
        if (user.transactions != null && user.transactions.isNotEmpty) {
          print("Transactions récupérées: ${user.transactions}");
        } else {
          print("Aucune transaction disponible.");
        }

        currentUser.value = user;
      } else {
        print("Aucun utilisateur chargé.");
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Échec de la connexion');
      }

      // Chercher d'abord dans la collection distributors
      var userDoc = await FirebaseFirestore.instance
          .collection('distributors')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Si pas trouvé dans distributors, chercher dans clients
        userDoc = await FirebaseFirestore.instance
            .collection('clients')
            .doc(userCredential.user!.uid)
            .get();
      }

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Utilisateur non trouvé dans la base de données');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      currentUser.value = UserModel.fromJson(userData);
      await saveCurrentUser(currentUser.value!);

      Get.snackbar("Succès", "Connexion réussie !",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      String errorMessage = 'Une erreur est survenue lors de la connexion';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Aucun utilisateur trouvé avec cet email';
            break;
          case 'wrong-password':
            errorMessage = 'Mot de passe incorrect';
            break;
          case 'invalid-email':
            errorMessage = 'Email invalide';
            break;
          case 'user-disabled':
            errorMessage = 'Ce compte a été désactivé';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }

      Get.snackbar('Erreur', errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Erreur de connexion détaillée: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Inscription avec email
  Future<void> registerWithEmail(
      String email, String password, Map<String, dynamic> userData) async {
    isLoading.value = true;

    try {
      // Créer un utilisateur avec Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Utiliser l'ID Firebase comme ID utilisateur
      String userId = userCredential.user!.uid; // ID de l'utilisateur Firebase
      userData['id'] = userId; // Ajouter l'ID aux données utilisateur
      userData['balance'] = 0.0; // Initialiser le solde

      final role = userData['role'] ?? 'client';

      // Ajouter l'utilisateur à la collection appropriée dans Firestore
      await firebaseService.addUserToSpecificCollection(
        role: role,
        userData: userData,
      );

      // Récupérer l'utilisateur créé
      final newUser = await firebaseService.getUserById(userId);
      if (newUser != null) {
        currentUser.value = newUser;
      }

      Get.snackbar("Succès", "Compte créé avec succès !");
    } catch (e) {
      String errorMessage = 'Une erreur est survenue lors de l\'inscription';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Cet email est déjà utilisé';
            break;
          case 'weak-password':
            errorMessage = 'Le mot de passe est trop faible';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }

      Get.snackbar("Erreur", errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currentUser', jsonEncode(user.toJson()));
  }

  //Deconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      currentUser.value = null;
      Get.offAllNamed('/client/login'); // Redirection vers la page de connexion
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la déconnexion: ${e.toString()}");
    }
  }

  void _redirectUser(String role) {
    if (currentUser.value != null) {
      if (role == 'distributeur') {
        Get.offAllNamed('/distributor/home');
      } else {
        Get.offAllNamed('/client/home');
      }
    }
  }
}
