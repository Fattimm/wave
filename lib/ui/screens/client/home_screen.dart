import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/client_controller.dart';
import '../../widgets/circular_button.dart';
import '../../widgets/transaction_list.dart';

class ClientHomeScreen extends GetView<ClientController> {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenue Client"),
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
                          fontSize: 24, fontWeight: FontWeight.bold),
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
                  icon: Icons.history,
                  label: "Scanner",
                  onPressed: () => Get.toNamed('/client/scanner'),
                ),
                CircularButton(
                  icon: Icons.send,
                  label: "Transfert",
                  onPressed: () => Get.toNamed('/client/transfer'),
                ),
                CircularButton(
                  icon: Icons.group_add,
                  label: "Transfert Multiple",
                  onPressed: () => Get.toNamed('/client/multiple-transfer'),
                ),
                CircularButton(
                  icon: Icons.schedule,
                  label: "Planification",
                  onPressed: () => Get.toNamed('/client/schedule'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Obx(() => Expanded(
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : TransactionsList(
                          transactions:
                              controller.currentUser.value?.transactions ?? [],
                        ),
                )),
          ],
        ),
      ),
    );
  }
}
