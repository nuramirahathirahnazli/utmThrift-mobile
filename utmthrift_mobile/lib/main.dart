import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utmthrift_mobile/viewmodels/signup_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/signin_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';

import 'views/pages/welcome_page.dart';
import 'views/pages/home_screen.dart';
import 'views/seller/seller_home_page.dart';
import 'views/seller/seller_add_item_page.dart';
import 'views/seller/seller_my_items_page.dart';

import 'views/profile/profile_screen.dart';
import 'views/auth/sign_up.dart';
import 'views/auth/sign_in.dart';

//test cors
import 'views/test-cors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SigninViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
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
        '/profile': (context) => const ProfileScreen(), 
        '/add_item': (context) => const AddItemScreen(),
        '/my_items': (context) => const MyItemsPage(),
        //nak test cors in flutter
        '/test_cors': (context) => CORSCheckScreen(),
      },
    );
  }
}
