import 'package:cloud_firestore/cloud_firestore.dart';

class Personne {
  String nom;
  int numero;
  Timestamp inscription;
  Timestamp dernierMoisPaye;

  Personne({
    required this.nom,
    required this.numero,
    required this.inscription,
    required this.dernierMoisPaye,
  });
}
