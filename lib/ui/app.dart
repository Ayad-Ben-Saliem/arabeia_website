import 'package:arabiya/main.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/add_edit_item_page.dart';
import 'package:arabiya/ui/cart_page.dart';
import 'package:arabiya/ui/checkout_page.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:arabiya/ui/invoice_page.dart';
import 'package:arabiya/ui/appearance_page.dart';
import 'package:arabiya/ui/invoices_page.dart';
import 'package:arabiya/ui/items_management_page.dart';
import 'package:arabiya/ui/reports_page.dart';
import 'package:arabiya/ui/item_page.dart';
import 'package:arabiya/ui/user_address_page.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_router/flutter_router.dart';

enum Mode {
  dark,
  light;

  static Mode fromString(String str) {
    for (final mode in values) {
      if (str == '$mode') return mode;
    }

    throw UnsupportedError('Unsupported Mode ($str)');
  }
}

final mode = StateProvider((ref) => Mode.fromString(sharedPreferences.getString('mode') ?? '${Mode.dark}'));

const currency = 'د.ل';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp(
      title: 'عَرَبِيَّة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ref.watch(mode) == Mode.dark ? const ColorScheme.dark(primary: Colors.white) : const ColorScheme.light(primary: Colors.blue),
        fontFamily: 'HacenTunisia',
        useMaterial3: false,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      locale: const Locale('ar'),
      initialRoute: '/',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      onGenerateRoute: Router({
        '/cart': (ctx, match, settings) => const CartPage(),
        '/address': (ctx, match, settings) => const UserAddressPage(),
        '/checkout': (ctx, match, settings) => const CheckoutPage(),
        '/add-item': (ctx, match, settings) => const AddEditItemPage(),
        '/edit-item': (ctx, match, settings) => AddEditItemPage(
              item: settings.arguments as Item?,
              id: match!.parameters['id'],
            ),
        '/invoices/{invoiceId}': (ctx, match, settings) {
          return InvoicePage(invoiceId: match!.parameters['invoiceId']!);
        },
        '/item/{id}': (ctx, match, settings) {
          return ItemPage(
            item: settings.arguments as Item?,
            id: match!.parameters['id'],
          );
        },
        '/appearance': (ctx, match, settings) => const AppearancePage(),
        '/invoices': (ctx, match, settings) => const InvoicesPage(),
        '/items': (ctx, match, settings) => const ItemsManagementPage(),
        '/reports': (ctx, match, settings) => const ReportsPage(),
        '/': (ctx, match, settings) => const HomePage(),
      }).get,
    );
  }
}
