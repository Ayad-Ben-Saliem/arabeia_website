import 'package:arabeia_website/ui/cart_page.dart';
import 'package:arabeia_website/ui/checkout_page.dart';
import 'package:arabeia_website/ui/home_page.dart';
import 'package:arabeia_website/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final darkMode = StateProvider((ref) => false);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp(
      title: 'عربية',
      theme: ThemeData(
        colorScheme: ref.watch(darkMode)
            ? const ColorScheme.dark(primary: Colors.white)
            : const ColorScheme.light(primary: Colors.black),
        fontFamily: 'HacenTunisia',
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomePage(),
        '/cart': (ctx) => const CartPage(),
        '/address': (ctx) => const UserAddressPage(),
        '/checkout': (ctx) => const CheckoutPage(),
      },
      locale: const Locale('ar'),
      // home: const HomePage(),
    );
  }
}
