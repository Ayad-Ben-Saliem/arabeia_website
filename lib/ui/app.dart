import 'package:arabeia_website/models/cart_item.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/ui/cart_page.dart';
import 'package:arabeia_website/ui/checkout_page.dart';
import 'package:arabeia_website/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabeia_website/ui/home_page.dart';

class CartItems extends StateNotifier<List<Item>> {
  CartItems()
      : super([
          Item(
            name: 'منتج اختبار',
            images: const ['https://i.postimg.cc/HYN3H0L8/IMG-5519.jpg'],
            price: 240,
            discount: 45,
          )
        ]);

  static final provider = StateNotifierProvider<CartItems, List<Item>>(
    (ref) => CartItems(),
  );

  static final sortedItemsProvider = StateProvider<Set<CartItem>>(
    (ref) {
      final items = ref.watch(CartItems.provider);

      final cartItems = <CartItem>{};
      for (final item in items) {
        var cartItem = CartItem(item: item, quantity: 1);
        for (CartItem cartItem0 in cartItems) {
          if (cartItem0.item == item) {
            cartItem = cartItem0.increase(1);
            cartItems.remove(cartItem0);
            break;
          }
        }
        cartItems.add(cartItem);
      }
      return cartItems;
    },
  );

  void removeItem(Item item, {int removeCount = -1}) {
    final items = <Item>[];
    for (final item0 in state.reversed) {
      if (item == item0) {
        removeCount == 0 ? items.add(item0) : removeCount--;
      } else {
        items.add(item0);
      }
    }
    state = items;
  }

  void addItem(Item item, {int count = 1}) {
    state = [
      ...state,
      for (int i = 0; i < count; i++) item.copyWith(),
    ];
  }

  void increaseQty(Item item, [int quantity = 1]) {
    addItem(item, count: quantity);
  }

  void decreaseQty(Item item, [int quantity = 1]) {
    if (state.contains(item)) {
      final items = List<Item>.from(state);
      int lastIndex = -1;
      for (int index = items.length - 1; index >= 0; index--) {
        if (items[index] == item) {
          lastIndex = index;
          break;
        }
      }
      items.removeAt(lastIndex);
      state = items;
    }
  }

  void setQuantity(Item item, int quantity) {}
}

final darkMode = StateProvider((ref) => false);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp(
      title: 'Arabeia',
      theme: ThemeData(
        colorScheme: ref.watch(darkMode)
            ? const ColorScheme.dark(primary: Colors.white)
            : const ColorScheme.light(primary: Colors.black),
        fontFamily: 'Tajawal-Regular.ttf',
        // fontFamily: 'RobotoMono',
        // useMaterial3: true,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const CartPage(),
    );
  }
}
