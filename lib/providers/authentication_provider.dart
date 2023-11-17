//Packages
//import 'package:confab/models/chat_user.dart';
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
    // Implementation of sending email verification
    // Use _auth.currentUser to get the current user
    // Call sendEmailVerification() on the user
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
  
  
  
}
