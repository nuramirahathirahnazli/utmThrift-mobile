import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utmthrift_mobile/viewmodels/signup_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/signin_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/event_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';

import 'views/pages/welcome_page.dart';
import 'views/seller/seller_home_page.dart';
import 'views/seller/seller_add_item_page.dart';
import 'views/seller/seller_my_items_page.dart';

import 'package:utmthrift_mobile/views/pages/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/auth/sign_up.dart';
import 'views/auth/sign_in.dart';

// test cors
import 'views/test-cors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SigninViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
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
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/home': (context) => const HomeScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/sign_in': (context) =>  SignInScreen(),
        '/seller_home': (context) => const SellerHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/add_item': (context) => const AddItemScreen(),
        '/my_items': (context) => const MyItemsPage(),

        // test cors
        '/test_cors': (context) =>  CORSCheckScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Page Not Found")),
          body: const Center(child: Text("404 - Page Not Found")),
        ),
      ),
    );
  }
}
