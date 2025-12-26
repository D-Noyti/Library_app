import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // LOGIN WITH EMAIL AND PASSWORD
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email, 
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  } 

  // REGISTER WITH EMAIL AND PASSWORD
  Future<void> createUserWithEmailAndPassword(String email, String password) async {  
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } 


  // CHANGE PASSWORD
  Future<void> changePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw 'Aucun utilisateur connecté';
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw 'Le mot de passe est trop faible';
        case 'requires-recent-login':
          throw 'Veuillez vous reconnecter pour changer votre mot de passe';
        default:
          throw 'Erreur: ${e.message}';
      }
    }
  }
}