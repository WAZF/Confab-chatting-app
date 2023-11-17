import 'package:confab/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:confab/firebase_options.dart';
//Packages
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

//Services
import './services/navigation_service.dart';

//Providers
import './providers/authentication_provider.dart';

//api
import './api/firebase_api.dart';

//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(
          MainApp(),
        );
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final NavigationService navigationService = NavigationService();
    final DatabaseService databaseService = DatabaseService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) {
            return AuthenticationProvider(
              firebaseAuth: firebaseAuth,
              googleSignIn: googleSignIn,
              navigationService: navigationService,
              databaseService: databaseService,
            );
          },
        )
      ],
      child: MaterialApp(
        title: 'Confab',
        theme: ThemeData(
          backgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
          scaffoldBackgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => LoginPage(),
          '/register': (BuildContext _context) => RegisterPage(),
          '/home': (BuildContext _context) => HomePage(),
        },
      ),
    );
  }
}
