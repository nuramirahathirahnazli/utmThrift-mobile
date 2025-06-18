// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:webview_flutter/webview_flutter.dart'; 
import 'package:webview_flutter_android/webview_flutter_android.dart'; 

import 'package:utmthrift_mobile/viewmodels/signup_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/signin_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/event_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/payment_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/review_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/sellerapplication_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/qrpayment_viewmodel.dart';

import 'views/pages/welcome_page.dart';
import 'views/seller/seller_home_page.dart';
import 'views/seller/seller_add_item_page.dart';
import 'views/seller/seller_my_items_page.dart';
import 'views/items/item_list_cart_page.dart';
import 'views/order/order_history_page.dart';

import 'views/pages/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/auth/sign_up.dart';
import 'views/auth/sign_in.dart';

// test cors
import 'views/test-cors.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SigninViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ChatMessageViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => SellerApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => QRPaymentViewModel()),
    
    ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

@override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // Set up WebView platform controller for Android
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => MaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => WelcomePage(),
          '/home': (context) => const HomeScreen(),
          '/sign_up': (context) => SignUpScreen(),
          '/sign_in': (context) => SignInScreen(),
          '/seller_home': (context) => const SellerHomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/add_item': (context) => const AddItemScreen(),
          '/my_items': (context) => const MyItemsPage(),
          '/cartPage': (context) => const CartPage(),
          '/order_history': (context) => const OrderHistoryPage(),

          // test cors
          '/test_cors': (context) => CORSCheckScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Page Not Found")),
            body: const Center(child: Text("404 - Page Not Found")),
          ),
        ),
      ),
    );
  }

}