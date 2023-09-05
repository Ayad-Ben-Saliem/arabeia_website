import 'package:arabeia_website/models/cart_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  static final itemsProvider =
      StateNotifierProvider<CartNotifier, List<CartItem>>(
    (ref) => CartNotifier(),
  );

  static final groupedItemsProvider = StateProvider<List<CartItem>>(
    (ref) {
      final items = ref.watch(CartNotifier.itemsProvider);

      final cartItems = <CartItem>[];
      for (int index = items.length - 1; index >= 0; index--) {
        final item = items[index];
        var cartItem = item.copyWith();
        for (CartItem cartItem0 in cartItems) {
          if (cartItem0 == item) {
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

  void removeItem(CartItem item, {int removeCount = -1}) {
    final items = <CartItem>[];
    for (final item0 in state.reversed) {
      if (item == item0) {
        removeCount == 0 ? items.add(item0) : removeCount--;
      } else {
        items.add(item0);
      }
    }
    state = items;
  }

  void addItem(CartItem item, {int count = 1}) {
    state = [
      ...state,
      for (int i = 0; i < count; i++) item.copyWith(),
    ];
  }

  void increaseQty(CartItem item, [int quantity = 1]) {
    addItem(item, count: quantity);
  }

  void decreaseQty(CartItem item, [int quantity = 1]) {
    if (state.contains(item)) {
      final items = List<CartItem>.from(state);
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

  void setQuantity(CartItem item, int quantity) {}
}
