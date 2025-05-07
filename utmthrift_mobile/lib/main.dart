import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utmthrift_mobile/viewmodels/signup_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/signin_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';

import 'views/pages/welcome_page.dart';
import 'views/pages/home_screen.dart';
import 'views/seller/seller_home_page.dart';

import 'views/profile/profile_screen.dart';
import 'views/auth/sign_up.dart';
import 'views/auth/sign_in.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SigninViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/sign_in': (context) => SignInScreen(),
        '/seller_home': (context) => const SellerHomeScreen(),
        '/profile': (context) => const ProfileScreen(), // Example of a route for Profile
      },
    );
  }
}
