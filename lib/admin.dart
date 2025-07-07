import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String moisEtAnnee(DateTime date) {
    return DateFormat.yMMMM('fr_FR').format(date);
  }

  void ajouterPersonne() {
    final nomController = TextEditingController();
    final numeroController = TextEditingController();
    DateTime? dateInscription;
    DateTime? dateDernierPaiement;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une personne'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                    TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Numéro'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateInscription != null
                                ? 'Inscription : ${moisEtAnnee(dateInscription!)}'
                                : 'Choisir inscription',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              locale: const Locale('fr', 'FR'),
                            );
                            if (picked != null) {
                              setState(() => dateInscription = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateDernierPaiement != null
                                ? 'Dernier payé : ${moisEtAnnee(dateDernierPaiement!)}'
                                : 'Choisir dernier paiement',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              locale: const Locale('fr', 'FR'),
                            );
                            if (picked != null) {
                              setState(() => dateDernierPaiement = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Ajouter'),
              onPressed: () async {
                final nom = nomController.text.trim();
                final numero = int.tryParse(numeroController.text.trim());

                if (nom.isNotEmpty &&
                    numero != null &&
                    dateInscription != null &&
                    dateDernierPaiement != null) {
                  await FirebaseFirestore.instance.collection('syndic').add({
                    'nom': nom,
                    'numero': numero,
                    'inscription': Timestamp.fromDate(dateInscription!),
                    'dernierMoisPaye': Timestamp.fromDate(dateDernierPaiement!),
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Situation des cotisations',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('syndic')
            .orderBy('numero')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Aucun document trouvé'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final nom = data['nom'] ?? '---';
              final numero = data['numero'] ?? '---';
              final inscription = (data['inscription'] as Timestamp?)?.toDate();
              final dernierMoisPaye = (data['dernierMoisPaye'] as Timestamp?)
                  ?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nom,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Numéro $numero'),
                            if (inscription != null)
                              Text('Inscription : ${moisEtAnnee(inscription)}'),
                            if (dernierMoisPaye != null)
                              Text(
                                'Dernier mois payé : ${moisEtAnnee(dernierMoisPaye)}',
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue[800],
                            onPressed: () async {
                              if (dernierMoisPaye != null) {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: dernierMoisPaye,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                  locale: const Locale('fr', 'FR'),
                                );

                                if (picked != null) {
                                  await FirebaseFirestore.instance
                                      .collection('syndic')
                                      .doc(doc.id)
                                      .update({
                                        'dernierMoisPaye': Timestamp.fromDate(
                                          picked,
                                        ),
                                      });
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ajouterPersonne,
        tooltip: 'Ajouter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
