import 'package:arabeia_website/models/cart_item.dart';

class Bill {
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final double latitude;
  final double longitude;
  final Iterable<CartItem> cartItems;
  final DateTime createAt;

  const Bill({
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.latitude,
    required this.longitude,
    required this.cartItems,
    required this.createAt,
  });

  double get total {
    var total = 0.0;
    for (final cartItem in cartItems) {
      total += cartItem.totalPrice;
    }
    return total;
  }

}
