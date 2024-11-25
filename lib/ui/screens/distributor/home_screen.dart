import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/distributor_controller.dart';
import '../../widgets/circular_button.dart';
import '../../widgets/transaction_list.dart';

class DistributorHomeScreen extends GetView<DistributorController> {
  const DistributorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenue Distributeur"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => Get.toNamed('/client/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section du solde avec Obx individuels
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.balanceVisible.value
                      ? "Solde: ${controller.currentUser?.value?.balance ?? 0.0} FCFA"
                      : "Solde: ****",
                  style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                IconButton(
                  icon: Icon(
                    controller.balanceVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                  onPressed: controller.toggleBalanceVisibility,
                ),
              ],
            )),

            const SizedBox(height: 16),

            // Boutons statiques (pas besoin de Obx)
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 14.0,
              crossAxisSpacing: 16.0,
              children: [
                CircularButton(
                  icon: Icons.attach_money,
                  label: "Dépôt",
                  onPressed: () => Get.toNamed('/distributor/deposit'),
                ),
                CircularButton(
                  icon: Icons.money_off,
                  label: "Retrait",
                  onPressed: () => Get.toNamed('/distributor/withdrawal'),
                ),
                CircularButton(
                  icon: Icons.arrow_upward,
                  label: "Déplafonnement",
                  onPressed: () => Get.toNamed('/distributor/limit-increase'),
                ),
                CircularButton(
                  icon: Icons.camera_alt,
                  label: "Scanner",
                  onPressed: () => Get.toNamed('/distributor/scanner'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Liste des transactions réactive
            Obx(() => Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : TransactionsList(
                      transactions: controller.transactions,
                    ),
            )),
          ],
        ),
      ),
    );
  }
}
