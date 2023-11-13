import 'package:arabiya/models/cart_item.dart';
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

  void addItem(CartItem cartItem) {
    final index = state.indexWhere(
      (cartItem0) =>
          cartItem.item == cartItem0.item && cartItem.size == cartItem0.size,
    );

    if (index == -1) {
      state = [...state, cartItem.copyWith()];
    } else {
      final currentItem = state[index].increase(cartItem.quantity);
      final items = List<CartItem>.from(state);
      items.replaceRange(index, index + 1, [currentItem]);
      state = items;
    }
  }
  
  void removeItem(CartItem cartItem) {
    final index = state.indexWhere(
          (cartItem0) =>
      cartItem.item == cartItem0.item && cartItem.size == cartItem0.size,
    );

    if(index != -1) {
      final currentItem = state[index].decrease(cartItem.quantity);
      final items = List<CartItem>.from(state);
      if(currentItem.quantity > 0) {
        items.replaceRange(index, index + 1, [currentItem]);
      } else {
        items.removeAt(index);
      }
      state = items;
    }
  }

  void setQuantity(CartItem item, int quantity) {}

  void empty() {
    state = [];
  }
}
