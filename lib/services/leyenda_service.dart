import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leyenda.dart';
import '../models/comentario.dart';

class LeyendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'leyendas';

  // Helper para mapear un DocumentSnapshot a un objeto Leyenda de forma segura
  Leyenda _mapToLeyenda(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Leyenda(
      id: doc.id,
      titulo: data?['titulo'] ?? 'Sin título',
      departamento: data?['departamento'] ?? 'desconocido',
      descripcionCorta: data?['descripcionCorta'] ?? '',
      descripcionLarga: data?['descripcionLarga'] ?? '',
      imagen: data?['imagen'] ?? '📖',
      origen: data?['origen'] ?? 'Desconocido',
      nivelDeTerror: data?['nivelDeTerror'] as int? ?? 3,
      ritualDeProteccion: data?['ritualDeProteccion'] as String? ?? 
          'No se conoce un ritual específico de protección. Mantente alerta.',
      horaAparicion: data?['horaAparicion'] as String? ?? 'Durante la noche',
      habitat: data?['habitat'] as String? ?? 'Desconocido',
      userId: data?['userId'],
    );
  }

  // Crear una nueva leyenda
  Future<String> crearLeyenda({
    required String userId,
    required String titulo,
    required String departamento,
    required String descripcionCorta,
    required String descripcionLarga,
    required String imagen,
    required String origen,
    int nivelDeTerror = 3,
    String ritualDeProteccion = 'No se conoce un ritual específico de protección. Mantente alerta.',
    String horaAparicion = 'Durante la noche',
    String habitat = 'Desconocido',
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'userId': userId,
        'titulo': titulo,
        'departamento': departamento,
        'descripcionCorta': descripcionCorta,
        'descripcionLarga': descripcionLarga,
        'imagen': imagen,
        'origen': origen,
        'nivelDeTerror': nivelDeTerror,
        'ritualDeProteccion': ritualDeProteccion,
        'horaAparicion': horaAparicion,
        'habitat': habitat,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Error al crear leyenda: $e';
    }
  }

  // Obtener leyendas por departamento
  Future<List<Leyenda>> obtenerLeyendasPorDepartamento(String departamento) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('departamento', isEqualTo: departamento)
          .get();

      return snapshot.docs.map((doc) => _mapToLeyenda(doc)).toList();
    } catch (e) {
      throw 'Error al obtener leyendas: $e';
    }
  }

  // Obtener todas las leyendas
  Future<List<Leyenda>> obtenerTodasLasLeyendas() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => _mapToLeyenda(doc)).toList();
    } catch (e) {
      throw 'Error al obtener leyendas: $e';
    }
  }

  // Obtener leyendas del usuario
  Future<List<Leyenda>> obtenerMisLeyendas(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapToLeyenda(doc)).toList();
    } catch (e) {
      throw 'Error al obtener tus leyendas: $e';
    }
  }

  // Actualizar leyenda
  Future<void> actualizarLeyenda({
    required String id,
    required String titulo,
    required String departamento,
    required String descripcionCorta,
    required String descripcionLarga,
    required String imagen,
    required String origen,
    int? nivelDeTerror,
    String? ritualDeProteccion,
    String? horaAparicion,
    String? habitat,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'titulo': titulo,
        'departamento': departamento,
        'descripcionCorta': descripcionCorta,
        'descripcionLarga': descripcionLarga,
        'imagen': imagen,
        'origen': origen,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (nivelDeTerror != null) updateData['nivelDeTerror'] = nivelDeTerror;
      if (ritualDeProteccion != null) updateData['ritualDeProteccion'] = ritualDeProteccion;
      if (horaAparicion != null) updateData['horaAparicion'] = horaAparicion;
      if (habitat != null) updateData['habitat'] = habitat;

      await _firestore.collection(_collection).doc(id).update(updateData);
    } catch (e) {
      throw 'Error al actualizar leyenda: $e';
    }
  }

  // Eliminar leyenda
  Future<void> eliminarLeyenda(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Error al eliminar leyenda: $e';
    }
  }

  // Stream de leyendas por departamento (actualización en tiempo real)
  Stream<List<Leyenda>> streamLeyendasPorDepartamento(String departamento) {
    return _firestore
        .collection(_collection)
        .where('departamento', isEqualTo: departamento)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapToLeyenda(doc)).toList());
  }

  // ──────────────────────────────────────────
  // SOPORTE DE COMENTARIOS (FIRESTORE SUBCOLLECTION)
  // ──────────────────────────────────────────

  // Stream de comentarios en tiempo real
  Stream<List<Comentario>> streamComentarios(String leyendaId) {
    return _firestore
        .collection(_collection)
        .doc(leyendaId)
        .collection('comentarios')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comentario.fromFirestore(doc))
            .toList());
  }

  // Agregar un nuevo comentario
  Future<void> agregarComentario({
    required String leyendaId,
    required String userId,
    required String userName,
    required String texto,
  }) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(leyendaId)
          .collection('comentarios')
          .add({
        'userId': userId,
        'userName': userName,
        'texto': texto,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error al agregar comentario: $e';
    }
  }
}
