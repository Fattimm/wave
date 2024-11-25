import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/client_controller.dart';


class TransferScreen extends GetView<ClientController> {
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfert d'argent"),
        elevation: 0,
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carte du solde
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "Solde disponible",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "${controller.currentUser.value?.balance.toStringAsFixed(2) ?? '0'} FCFA",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Champ numéro de téléphone
                    TextFormField(
                      controller: recipientController,
                      decoration: InputDecoration(
                        labelText: "Numéro du destinataire",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro de téléphone';
                        }
                        if (value.length < 8) {
                          return 'Numéro de téléphone invalide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Champ montant
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: "Montant à transférer",
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: "FCFA",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // Information sur les frais
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Des frais de 1% seront appliqués à ce transfert",
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Bouton de transfert
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final amount = double.tryParse(amountController.text) ?? 0;
                                await controller.transfer(
                                  recipientController.text,
                                  amount,
                                );
                              }
                            },
                      child: Text(
                        "Effectuer le transfert",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
  }
}