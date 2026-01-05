import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    if (credential.user != null) {
      final newUser = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
      );

      await _createUserDoc(newUser);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  DocumentReference<UserModel> _userDoc(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .withConverter<UserModel>(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        );
  }

  Future<void> _createUserDoc(UserModel user) async {
    await _userDoc(user.id).set(user);
  }

  Future<UserModel?> getUserData(String uid) async {
    final docSnap = await _userDoc(uid).get();
    return docSnap.data();
  }

  Future<void> updateUserData(UserModel user) async {
    await _userDoc(user.id).set(user, SetOptions(merge: true));
  }
}
