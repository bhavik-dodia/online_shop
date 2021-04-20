import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/carts_data.dart';
import 'providers/products_data.dart';
import 'screens/auth_page.dart';
import 'screens/carts_page.dart';
import 'screens/home_page.dart';
import 'screens/orders/orders_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ProductsData(),
          ),
          ChangeNotifierProvider(
            create: (context) => CartsData(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Online Shop',
          theme: ThemeData(
            primaryColor: Colors.blueAccent,
            accentColor: Colors.blueAccent,
            appBarTheme: appBarTheme(),
            textTheme: GoogleFonts.lailaTextTheme(),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueAccent,
            accentColor: Colors.blueAccent,
            appBarTheme: appBarTheme(),
            textTheme: GoogleFonts.lailaTextTheme(
              theme.textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: snapshot.data == null ? AuthPage() : HomePage(),
          routes: {
            HomePage.routeName: (context) => HomePage(),
            CartsPage.routeName: (context) => CartsPage(),
            OrdersPage.routeName: (context) => OrdersPage(),
          },
        ),
      ),
    );
  }

  AppBarTheme appBarTheme() {
    return AppBarTheme(
      elevation: 0.0,
      centerTitle: true,
      color: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.blueAccent, size: 25.0),
      actionsIconTheme: const IconThemeData(
        color: Colors.blueAccent,
        size: 30.0,
      ),
      textTheme: TextTheme(
        headline6: GoogleFonts.alice(
          fontSize: 25.0,
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
