import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String userId;
  final String userName;
  final String texto;
  final DateTime createdAt;

  Comentario({
    required this.id,
    required this.userId,
    required this.userName,
    required this.texto,
    required this.createdAt,
  });

  factory Comentario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    // Manejo seguro del timestamp de creación
    DateTime createdDate = DateTime.now();
    if (data?['createdAt'] != null) {
      if (data!['createdAt'] is Timestamp) {
        createdDate = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
      }
    }

    return Comentario(
      id: doc.id,
      userId: data?['userId'] ?? 'anonimo',
      userName: data?['userName'] ?? 'Anónimo',
      texto: data?['texto'] ?? '',
      createdAt: createdDate,
    );
  }
}
