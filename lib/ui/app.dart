import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/cart_page.dart';
import 'package:arabiya/ui/checkout_page.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:arabiya/ui/item_page.dart';
import 'package:arabiya/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_router/flutter_router.dart' as FRouter;

final darkMode = StateProvider((ref) => false);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        title: 'عربية',
        theme: ThemeData(
          colorScheme: ref.watch(darkMode)
              ? const ColorScheme.dark(primary: Colors.white)
              : const ColorScheme.light(primary: Colors.black),
          fontFamily: 'HacenTunisia',
        ),
        locale: const Locale('ar'),
        initialRoute: '/',
        // routes: {
        //   '/': (ctx) => const HomePage(),
        //   '/cart': (ctx) => const CartPage(),
        //   '/address': (ctx) => const UserAddressPage(),
        //   '/checkout': (ctx) => const CheckoutPage(),
        // },
        onGenerateRoute: FRouter.Router({
          '/cart': (ctx, match, settings) => const CartPage(),
          '/address': (ctx, match, settings) => const UserAddressPage(),
          '/checkout': (ctx, match, settings) => const CheckoutPage(),
          '/item/{id}': (ctx, match, settings) {
            return ItemPage(
              item: settings.arguments as Item?,
              id: match!.parameters['id']!,
            );
          },
          '/': (ctx, match, settings) => const HomePage(),
        }).get,
        // home: const HomePage(),
      ),
    );
  }
}
