import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/distributor_controller.dart';

class DistributorHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final distributorController = Get.find<DistributorController>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil Distributeur"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Get.toNamed('/distributor/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      distributorController.balanceVisible.value
                          ? "Solde: ${distributorController.currentUser?.balance ?? 0.0} FCFA"
                          : "Solde: ****",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )),
                IconButton(
                  icon: Obx(() => Icon(
                        distributorController.balanceVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue,
                      )),
                  onPressed: distributorController.toggleBalanceVisibility,
                ),
              ],
            ),
            SizedBox(height: 16),

            // GridView pour les fonctionnalités principales
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Nombre de colonnes
                mainAxisSpacing: 14.0, // Espacement vertical entre les boutons
                crossAxisSpacing: 16.0, // Espacement horizontal entre les boutons
                childAspectRatio: 1.2, // Ratio de largeur/hauteur
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/distributor/deposit'),
                    icon: Icon(Icons.attach_money, color: Colors.blue, size: 24),
                    label: Text("Dépôt", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/distributor/withdrawal'),
                    icon: Icon(Icons.money_off, color: Colors.blue, size: 24),
                    label: Text("Retrait", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/distributor/limit-increase'),
                    icon: Icon(Icons.arrow_upward, color: Colors.blue, size: 24),
                    label: Text("Déplafonnement", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/distributor/scanner'),
                    icon: Icon(Icons.camera_alt, color: Colors.blue, size: 24),
                    label: Text("Scanner", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Liste des transactions
            Expanded(
              child: Obx(() {
                final transactions = distributorController.transactions;
                if (transactions.isEmpty) {
                  return Center(child: Text("Aucune transaction disponible."));
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      leading: Icon(Icons.monetization_on, color: Colors.blue),
                      title: Text("${transaction.type}"),
                      subtitle: Text(
                          "Montant: ${transaction.amount} FCFA\nDate: ${transaction.date}"),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        Get.toNamed('/distributor/transaction/${transaction.id}');
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
