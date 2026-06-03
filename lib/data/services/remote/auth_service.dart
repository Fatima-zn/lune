import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;



  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool isAtLeast13(DateTime dob) {
    final now = DateTime.now();
    return now.year - dob.year >= 13;
  }

  Future<void> signup({
        required String firstName,
        required String lastName,
        required DateTime dob,
        required String email,
        required String password
      }) async {
        final cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final user = cred.user;
        if (user != null){
          await user.sendEmailVerification();
          await _auth.signOut(); //In order to force email verif before first login
        }

        await _db.collection("users").doc(cred.user!.uid).set({
          "firstName": firstName,
          "lastName": lastName,
          "dob": Timestamp.fromDate(dob),
          "email": email,
        });
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload(); //Refresh user data from Firebase
    return _auth.currentUser!.emailVerified;
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }


  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> authState() {
    return _auth.authStateChanges();
  }


  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No user found");
    }

    await user.sendEmailVerification();
  }


  Future<void> sendPasswordResetEmail(String email) async {
    if (!isValidEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is not valid.',
      );
    }
    
    await _auth.sendPasswordResetEmail(email: email.trim());
  }


  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _db.collection("users").doc(user.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }



  Future<void> addFavoriteToFirestore(Map<String, dynamic> podcastData) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _db.collection("users").doc(user.uid).collection("favorites").doc(podcastData['id']).set({
      'id': podcastData['id'],
      'title': podcastData['title'],
      'image': podcastData['image'],
      'publisher': podcastData['publisher'],
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavoriteFromFirestore(String podcastId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _db.collection("users").doc(user.uid).collection("favorites").doc(podcastId).delete();
  }

  Future<List<Map<String, dynamic>>> getFavoritesFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    final snapshot = await _db
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .orderBy('addedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<bool> isFavoriteInFirestore(String podcastId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final doc = await _db
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(podcastId)
        .get();
    
    return doc.exists;
  }
}
