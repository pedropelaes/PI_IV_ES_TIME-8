import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Verificar se o Firebase está inicializado
  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  // Getter para o usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream para monitorar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método para cadastro de usuário
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    String? studentId,
  }) async {
    if (!_isFirebaseInitialized) {
      throw 'Firebase não está inicializado. Tente novamente em alguns segundos.';
    }
    
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar o perfil do usuário com o nome
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // Método para login do usuário
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseInitialized) {
      throw 'Firebase não está inicializado. Tente novamente em alguns segundos.';
    }
    
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // Método para reset de senha
  Future<void> resetPassword({required String email}) async {
    if (!_isFirebaseInitialized) {
      throw 'Firebase não está inicializado. Tente novamente em alguns segundos.';
    }
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // Método para logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Erro ao fazer logout: $e';
    }
  }

  // Método para tratar exceções do Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
