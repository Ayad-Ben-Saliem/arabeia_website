import 'package:arabiya/models/cart_item.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:arabiya/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات', textDirection: TextDirection.rtl),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Consumer(
            builder: (context, ref, widget) {
              final cartItems = ref.watch(CartNotifier.groupedItemsProvider);

              return Column(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isVertical = constraints.maxWidth < 300;
                      return ListView(
                        children: [
                          for (final cartItem in cartItems)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: isVertical
                                  ? vCard(cartItem)
                                  : hCard(cartItem),
                            ),
                        ],
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${total(cartItems)} $currency',
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/address'),
                      child: const Text(
                        'التالي',
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget vCard(CartItem cartItem) {
    return Card(
      child: Column(
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 128),
                child: Image.network(cartItem.item.images[0]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cartItem.item.name,
                    maxLines: 5,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: priceWidget(cartItem.item),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Text('الحجم', textDirection: TextDirection.rtl),
                    Text(cartItem.size, textDirection: TextDirection.rtl),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  textDirection: TextDirection.rtl,
                  children: [
                    qtyWidget(cartItem),
                    const SizedBox(height: 8),
                    Text('(${cartItem.totalPrice}) $currency',
                        textDirection: TextDirection.rtl),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget hCard(CartItem cartItem) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 128),
      child: Card(
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Image.network(cartItem.item.images[0]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cartItem.item.name,
                        maxLines: 5,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        priceWidget(cartItem.item),
                        Column(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Text(
                              'الحجم',
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              cartItem.size,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                textDirection: TextDirection.rtl,
                children: [
                  qtyWidget(cartItem),
                  const Spacer(),
                  Text(
                    '(${cartItem.totalPrice}) $currency',
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget qtyWidget(CartItem cartItem) {
    return Consumer(
      builder: (context, ref, widget) {
        return Row(
          textDirection: TextDirection.rtl,
          children: [
            IconButton(
              onPressed: () {
                ref
                    .read(CartNotifier.itemsProvider.notifier)
                    .increaseQty(cartItem);
              },
              icon: const Icon(Icons.add),
            ),
            Text('(${cartItem.quantity})', textDirection: TextDirection.rtl),
            IconButton(
              onPressed: () {
                if (cartItem.quantity == 1) {
                  removeItemConfirmationDialog(context, ref, cartItem);
                } else {
                  ref
                      .read(CartNotifier.itemsProvider.notifier)
                      .decreaseQty(cartItem);
                }
              },
              icon: const Icon(Icons.remove),
            ),
          ],
        );
      },
    );
  }

  void removeItemConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    CartItem cartItem,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'هل أنت متأكد من أنك تريد حذف هذا العنصر؟',
            textDirection: TextDirection.rtl,
          ),
          content: Text(cartItem.item.name, textDirection: TextDirection.rtl),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref
                    .read(CartNotifier.itemsProvider.notifier)
                    .decreaseQty(cartItem);
                Navigator.pop(context);
              },
              child: const Text('نعم', textDirection: TextDirection.rtl),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لا', textDirection: TextDirection.rtl),
            ),
          ],
        );
      },
    );
  }

  double total(Iterable<CartItem> cartItems) {
    var total = 0.0;
    for (final cartItem in cartItems) {
      total += cartItem.totalPrice;
    }
    return total;
  }

  Widget priceWidget(Item item) {
    if (item.discount != null) {
      return Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${item.price} $currency',
            textDirection: TextDirection.rtl,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
          Text(
            '${item.effectivePrice} $currency',
            textDirection: TextDirection.rtl,
          ),
        ],
      );
    }
    return Text(
      '${item.effectivePrice} $currency',
      textDirection: TextDirection.rtl,
    );
  }
}
