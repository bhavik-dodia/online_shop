import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Manages authentication using Google.
class GoogleLogIn {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Displays a dialog to select a Google Account for login.
  static signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final authResult = await _auth.signInWithCredential(credential);
    final _user = authResult.user;
    assert(!_user.isAnonymous);
    assert(await _user.getIdToken() != null);
    User currentUser = _auth.currentUser;
    assert(_user.uid == currentUser.uid);
    FirebaseFirestore.instance
        .collection('Users')
        .doc(authResult.user.uid)
        .set({
      'id': authResult.user.uid,
      'name': authResult.user.displayName,
      'email': authResult.user.email,
      'imageUrl': authResult.user.photoURL,
    });
  }

  /// Signs out logged in user.
  static signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
