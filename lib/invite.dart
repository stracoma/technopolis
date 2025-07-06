import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  String moisEtAnnee(DateTime date) {
    return DateFormat.yMMMM('fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotisations')),
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
              final data = docs[index].data() as Map<String, dynamic>;
              final nom = data['nom'] ?? '---';
              final numero = data['numero'] ?? '---';
              final inscription = (data['inscription'] as Timestamp?)?.toDate();
              final dernierMoisPaye = (data['dernierMoisPaye'] as Timestamp?)
                  ?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
              );
            },
          );
        },
      ),
    );
  }
}
