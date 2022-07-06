import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    return user.user;
  }

  Future signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      googleSignIn.signOut();
    }
    return await _auth.signOut();
  }

  Future<String> createUser(String email, String password) async {
    final time = DateTime.now();

    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    var result = user.user;
    var userId = result!.uid;

    await _firestore
        .collection(_usersCollection)
        .doc(userId).set({'status':true});

    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('profileInfo')
        .doc()
        .set({
      'email': email,
      'avatarURL': null,
      'createdTime': time,
    });

    return userId;
  }

  Future<String> createGoogleUser(String email, String id,
      String avatarURL) async {
    final time = DateTime.now();

    await _firestore
        .collection(_usersCollection)
        .doc(id).set({'status':true});

    await _firestore
        .collection(_usersCollection)
        .doc(id)
        .collection('profileInfo')
        .doc()
        .set({
      'email': email,
      'avatarURL': avatarURL,
      'createdTime': time,
    });

    return id;
  }

  Future<void> updateUser(String? id,
      [String? username, String? fullName, String? phoneNumber]) async {
    var profileInfoDoc = _firestore
        .collection(_usersCollection)
        .doc(id)
        .collection('profileInfo')
        .get();
    var docID = await profileInfoDoc.then((value) => value.docs[0].id);
    await _firestore
        .collection(_usersCollection)
        .doc(id)
        .collection('profileInfo')
        .doc(docID)
        .update({
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    });
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

const String _usersCollection = "Users";
