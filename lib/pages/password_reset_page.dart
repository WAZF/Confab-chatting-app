import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

// Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

// Providers
import '../providers/authentication_provider.dart';

// Services
import '../services/navigation_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordPageState();
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  final _resetPasswordFormKey = GlobalKey<FormState>();

  String? _email;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return _buildUI();
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
            _resetPasswordForm(),
            SizedBox(
              height: _deviceHeight * 0.02,
            ),
            _resetPasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.10,
      child: Text(
        'Reset Password',
        style: TextStyle(
          fontFamily: 'Pacifico',
          color: const Color.fromARGB(255, 246, 241, 171),
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _resetPasswordForm() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Form(
        key: _resetPasswordFormKey,
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
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resetPasswordButton() {
    return RoundedButton(
      name: "Reset Password",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () {
        if (_resetPasswordFormKey.currentState!.validate()) {
          _resetPasswordFormKey.currentState!.save();
          // Implement your reset password logic here
          // Example: _auth.resetPassword(_email!);

          // Navigate back to login page after resetting password
          _navigation.navigateToRoute('/login');
        }
      },
    );
  }
}
