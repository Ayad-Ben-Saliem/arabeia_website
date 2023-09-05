import 'package:arabeia_website/models/item.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final Item item;
  final String size;
  final int quantity;

  const CartItem({
    required this.item,
    required this.size,
    required this.quantity,
  });

  CartItem.copyWith(
      CartItem cartItem, {
        Item? item,
        String? size,
        int? quantity,
      })  : item = item ?? cartItem.item,
  size = size ?? cartItem.size,
        quantity = quantity ?? cartItem.quantity;

  CartItem copyWith({
    Item? item,
    String? size,
    int? quantity,
  }) {
    return CartItem.copyWith(
      this,
      item: item,
      size: size,
      quantity: quantity,
    );
  }

  CartItem increase(int quantity) {
    return CartItem.copyWith(
      this,
      quantity: this.quantity + quantity,
    );
  }

  CartItem decrease(int quantity) {
    return CartItem.copyWith(
      this,
      quantity: this.quantity - quantity,
    );
  }

  double get totalPrice => item.effectivePrice * quantity;

  @override
  List<Object?> get props => [
    item,
    size,
    quantity,
    totalPrice,
  ];

}
