import 'package:ecofind/Components/BottomNavigation.dart';
import 'package:ecofind/Pages/HomePage.dart';
import 'package:ecofind/Pages/NewProduct.dart';
import 'package:ecofind/Pages/Onboarding.dart';
import 'package:ecofind/Pages/ProductsPage.dart';
import 'package:ecofind/Pages/ProfilePage.dart';
import 'package:ecofind/Pages/suppose.dart';
import 'package:flutter/material.dart';
import 'package:ecofind/Pages/LoginPage.dart';
import 'package:ecofind/UserDetails/SignUpPage.dart';
import 'package:ecofind/Pages/CartPage.dart';

void main() {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      // theme: ThemeData(
      //     fontFamily: "LibertinusSerif"
      // ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboard',
      routes: {
        '/':(context) => EcoFindsLandingPage(),
        '/2':(context) => EcoFindsLandingPage2(),
        '/login':(context) =>  LoginPage(),
        '/signup':(context) => SignUpPage(),
        '/cart':(context) => CartPage(),
        '/addnew':(context) => AddProductPage(),
        '/profile':(context) => DashboardPage(),
        '/products':(context) => ProductPage(),
        '/onboard':(context) => OnboardingScreen(),
        '/bottom':(context) => NavBar(),

      },
    );
  }
}

