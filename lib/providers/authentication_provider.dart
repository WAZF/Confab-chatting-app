//Packages
//import 'package:confab/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

//api
import '../api/firebase_api.dart';
//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Models
import '../models/chat_user.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  late ChatUser user;

  AuthenticationProvider({required FirebaseAuth firebaseAuth,
      required GoogleSignIn googleSignIn,
      required NavigationService navigationService,
      required DatabaseService databaseService})
    : _auth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _navigationService = navigationService,
        _databaseService = databaseService {
    
    _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        _databaseService.updateUserLastSeenTime(_user.uid);
        _databaseService.getUser(_user.uid).then(
          (_snapshot) {
            Map<String, dynamic> _userData =
                _snapshot.data()! as Map<String, dynamic>;
            user = ChatUser.fromJSON(
              {
                "uid": _user.uid,
                "name": _userData["name"],
                "email": _userData["email"],
                "last_active": _userData["last_active"],
                "image": _userData["image"],
              },
            );
            _navigationService.removeAndNavigateToRoute('/home');
          },
        );
      } else {
        if (_navigationService.getCurrentRoute() != '/login') {
          _navigationService.removeAndNavigateToRoute('/login');
        }
      }
    });
  }

 Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
    return null;
  }


  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException {
      print("Error logging user into Firebase");
    } catch (e) {
      print(e);
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await currentUser.reload();
        return currentUser.emailVerified;
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking email verification: $e");
      return false;
    }
  }

  Future<void> sendEmailVerification() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Email verification sent to ${user.email}');
    } else {
      print('User is either null or email is already verified');
    }
  } catch (e) {
    print('Error sending email verification: $e');
    // Handle the error, show a message to the user, etc.
  }
}

  Future<String?> registerUserUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      UserCredential _credentials = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return _credentials.user!.uid;
    } on FirebaseAuthException {
      print("Error registering user.");
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
  
  Future<String?> getCurrentUserImageURL() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      // Fetch the user data from the database
      DocumentSnapshot userData = await _databaseService.getUser(currentUser.uid);
      String? imageURL = userData.get('image') as String?;
      return imageURL;
    }

    return null; // Return null if the user is not logged in
  }

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

}
