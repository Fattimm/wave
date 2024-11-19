import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/client_controller.dart';

class ClientHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final clientController = Get.find<ClientController>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil Client"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Get.toNamed('/client/settings');
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
                      clientController.balanceVisible.value
                          ? "Solde: ${clientController.currentUser?.balance ?? 0.0} FCFA"
                          : "Solde: ****",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )),
                IconButton(
                  icon: Obx(() => Icon(
                        clientController.balanceVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue,
                      )),
                  onPressed: clientController.toggleBalanceVisibility,
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Nombre de colonnes
                mainAxisSpacing: 14.0, // Espacement vertical entre les boutons
                crossAxisSpacing: 16.0, // Espacement horizontal entre les boutons
                childAspectRatio: 1.2, // Ratio de largeur/hauteur pour réduire la taille
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/client/scanner'),
                    icon: Icon(Icons.history, color: Colors.blue, size: 24), // Taille de l'icône
                    label: Text("Scanner", style: TextStyle(fontSize: 16)), // Taille du texte
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10), // Ajustez le padding
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/client/transfer'),
                    icon: Icon(Icons.send, color: Colors.blue, size: 24),
                    label: Text("Transfert", style: TextStyle(fontSize: 16)),
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
                    onPressed: () => Get.toNamed('/client/multiple-transfer'),
                    icon: Icon(Icons.group_add, color: Colors.blue, size: 24),
                    label: Text("Transfert Multiple", style: TextStyle(fontSize: 16)),
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
                    onPressed: () => Get.toNamed('/client/schedule'),
                    icon: Icon(Icons.schedule, color: Colors.blue, size: 24),
                    label: Text("Planification", style: TextStyle(fontSize: 16)),
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
            Expanded(
              child: Obx(() {
                final transactions = clientController.transactions;
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
                      subtitle: Text("Montant: ${transaction.amount} FCFA\nDate: ${transaction.date}"),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
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
