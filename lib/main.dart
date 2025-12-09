import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fashion_store_app/screens/home_screen.dart';
import 'package:fashion_store_app/screens/product_details_screen.dart';
import 'package:fashion_store_app/screens/cart_screen.dart';
import 'package:fashion_store_app/providers/cart_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Fashion Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0.5,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
            bodyColor: Colors.black87,
            displayColor: Colors.black87,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(
            secondary: Colors.deepOrangeAccent, // Cor de destaque
          ),
        ),
        home: const HomeScreen(),
        routes: {
          ProductDetailsScreen.routeName: (ctx) => const ProductDetailsScreen(),
          CartScreen.routeName: (ctx) => const CartScreen(),
        },
      ),
    );
  }
}