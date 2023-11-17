import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:file_picker/file_picker.dart';
// Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

// Providers
import '../providers/authentication_provider.dart';

// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late GoogleSignIn _googleSignIn;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late NavigationService _navigation;

  PlatformFile? photoURL;

  final _loginFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return _buildUI();
  }
  

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          final _name = firebaseUser.displayName;
          final _email = firebaseUser.email;
          final photoURL = firebaseUser.photoURL;

          if (_email != null) {
            // Check if the user already exists in your database, if not, create a new user
            bool userExists = await _db.checkIfUserExists(_email);
            if (!userExists) {
              String? _uid = await _auth.registerUserUsingEmailAndPassword(
                  _email, 'temporary_password');
              String? _imageURL = photoURL; // Use the retrieved photo URL
              await _db.createUser(_uid!, _email, _name!, _imageURL!);
              await _auth.loginUsingEmailAndPassword(_email, _password!);
            }

            // Navigate to home page or perform other actions based on user creation/login
          }
        }
      } else {
        // User canceled sign-in
        print('User canceled sign-in');
      }
    } catch (error) {
      // Handle sign-in errors
      print('Error signing in: $error');
    }
  }

  Widget _buildUI() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pageTitle(),
            SizedBox(
              height: _deviceHeight * 0.04,
            ),
            _loginForm(),
            SizedBox(
              height: _deviceHeight * 0.02,
            ),
            _forgotPasswordLink(),
            SizedBox(
              height: _deviceHeight * 0.03,
            ),
            _loginButton(),
            SizedBox(
              height: _deviceHeight * 0.04,
            ),
            _registerAccountLink(),
            SizedBox(
              height: _deviceHeight * 0.02,
            ),
            ortext(),
            SizedBox(
              height: _deviceHeight * 0.02,
            ),
            _googleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.10,
      child: Text(
        'Confab',
        style: TextStyle(
          fontFamily: 'Pacifico',
          color: const Color.fromARGB(255, 246, 241, 171),
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: _deviceHeight * 0.18,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _email = _value;
                  });
                },
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Email",
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regEx: r".{7,}",
                hintText: "Password",
                obscureText: true),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return RoundedButton(
      name: "Login",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () {
        if (_loginFormKey.currentState!.validate()) {
          _loginFormKey.currentState!.save();
          _auth.loginUsingEmailAndPassword(_email!, _password!);
        }
      },
    );
  }

  Widget _forgotPasswordLink() {
    return GestureDetector(
      onTap: _showForgotPasswordDialog,
      child: Padding(
        padding:
            EdgeInsets.only(left: 16.0), // Adjust the left padding as needed
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color.fromARGB(255, 164, 64, 221),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerAccountLink() {
    return GestureDetector(
      onTap: () => {
        _showRegisterMessage(),
      },
      child: Container(
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: Color.fromARGB(255, 246, 241, 171),
            ),
            children: [
              TextSpan(
                text: 'Register now',
                style: TextStyle(
                  color: Color.fromARGB(255, 164, 64, 221),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Container(
            height: _deviceHeight * 0.12,
            child: Form(
              key: _resetPasswordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTextFormField(
                    onSaved: (_value) {
                      setState(() {
                        _email = _value;
                      });
                    },
                    regEx:
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    hintText: "Email",
                    obscureText: false,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(
                    255, 254, 124, 114), // Change this to your desired color
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_resetPasswordFormKey.currentState!.validate()) {
                  _resetPasswordFormKey.currentState!.save();

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _email!,
                    );

                    // Password reset email sent successfully
                    print('Password reset email sent to $_email');

                    // Close the dialog
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle errors, e.g., if the email is not found
                    print('Error sending password reset email: $e');
                    // You might want to show an error message to the user
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(
                    243, 188, 105, 1), // Change this to your desired color
              ),
              child: Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Registration Note!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'New users are requested to register their account with profile image and valid email address, username must be contains 6 letters and password must contain at least 8 letters.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(
                            255, 254, 124, 114), // Set your cancel button color
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigation.navigateToRoute('/register');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(
                            243, 188, 105, 1), // Set your OK button color
                      ),
                      child: Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget ortext() {
    return Text ('or',style: TextStyle(color: Colors.white),);
  }


Widget _googleSignInButton() {
  return SizedBox(
    height: 50.0, // Set your custom height
    width: 250.0, // Set your custom width
    child: TextButton.icon(
      onPressed: _handleSignIn,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      icon: Image.asset(
        'assets/images/google_logo.png',
        height: 24.0, // Adjust the height of the Google logo
        width: 24.0, // Adjust the width of the Google logo
      ),
      label: Text(
        'Sign in with Google',
        style: TextStyle(
          color: Colors.black, // Change text color as needed
        ),
      ),
    ),
  );
}

}
