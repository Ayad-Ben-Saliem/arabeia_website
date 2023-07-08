import 'package:arabeia_website/models/item.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final Item item;
  final int quantity;

  CartItem({
    required this.item,
    required this.quantity,
  });

  CartItem.copyWith(
      CartItem cartItem, {
        Item? item,
        int? quantity,
      })  : item = item ?? cartItem.item,
        quantity = quantity ?? cartItem.quantity;

  CartItem copyWith({
    Item? item,
    int? quantity,
  }) {
    return CartItem.copyWith(
      this,
      item: item,
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
    quantity,
    totalPrice,
  ];

}
