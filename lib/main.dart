import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';
import 'bindings/client_binding.dart';
import 'bindings/distributor_binding.dart';
import '../ui/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialisez Firebase
  Get.put(AuthController()); // AuthController ajouté ici
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/client/login',
      getPages: AppRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
