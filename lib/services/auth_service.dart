import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrarse con email y contraseña
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar displayName
      await userCredential.user?.updateDisplayName(displayName);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        throw 'Este email ya está registrado.';
      }
      throw e.message ?? 'Error en el registro';
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No existe usuario con este email.';
      } else if (e.code == 'wrong-password') {
        throw 'Contraseña incorrecta.';
      } else if (e.code == 'invalid-email') {
        throw 'Email no válido.';
      }
      throw e.message ?? 'Error al iniciar sesión';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error al enviar email de recuperación';
    }
  }
}
