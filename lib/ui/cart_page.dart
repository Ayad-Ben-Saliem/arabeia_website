import 'package:arabeia_website/models/cart_item.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/ui/app.dart';
import 'package:arabeia_website/ui/home_page.dart';
import 'package:arabeia_website/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Consumer(
            builder: (context, ref, widget) {
              final cartItems = ref.watch(CartItems.sortedItemsProvider);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        for (final cartItem in cartItems)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 128),
                              child: Card(
                                child: Row(
                                  children: [
                                    Image.network(cartItem.item.images[0]),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(cartItem.item.name),
                                          const Spacer(),
                                          priceWidget(cartItem.item),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          qtyWidget(cartItem),
                                          const Spacer(),
                                          Text(
                                            '(${cartItem.totalPrice}) $currency',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${total(cartItems)} $currency'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserAddressPage(),
                          ),
                        );
                      },
                      child: const Text('التالي'),
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

  Widget qtyWidget(CartItem cartItem) {
    return Consumer(
      builder: (context, ref, widget) {
        return Row(
          children: [
            IconButton(
              onPressed: () {
                ref
                    .read(CartItems.provider.notifier)
                    .increaseQty(cartItem.item);
              },
              icon: const Icon(Icons.add),
            ),
            Text('(${cartItem.quantity})'),
            IconButton(
              onPressed: () {
                if (cartItem.quantity == 1) {
                  removeItemConfirmationDialog(context, ref, cartItem.item);
                } else {
                  ref
                      .read(CartItems.provider.notifier)
                      .decreaseQty(cartItem.item);
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
    Item item,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            height: 128,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('هل أنت متأكد من أنك تريد حذف هذا العنصر؟'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('(${item.name})'),
                ),
                const Spacer(),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(CartItems.provider.notifier)
                                .decreaseQty(item);
                            Navigator.pop(context);
                          },
                          child: const Text('نعم'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('لا'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        children: [
          Text(
            '${item.price} $currency',
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
          Text('${item.effectivePrice} $currency'),
        ],
      );
    }
    return Text('${item.effectivePrice} $currency');
  }
}
