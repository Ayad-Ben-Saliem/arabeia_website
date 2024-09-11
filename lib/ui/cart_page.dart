import 'package:arabiya/models/invoice_item.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/app.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/invoice_viewer.dart';
import 'package:arabiya/ui/widgets/full_screen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Consumer(
            builder: (context, ref, widget) {
              final invoiceItems = ref.watch(CartNotifier.groupedItemsProvider);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isVertical = constraints.maxWidth < 600;
                        return ListView(
                          children: [
                            for (final cartItem in invoiceItems)
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: isVertical ? vCard(cartItem) : hCard(cartItem),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${total(invoiceItems)} $currency'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: invoiceItems.isNotEmpty ? () => Navigator.pushNamed(context, '/address') : null,
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

  Widget vCard(InvoiceItem cartItem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FullScreenDialog(
                                images: cartItem.item.images,
                                initialImage: cartItem.item.images[0],
                              );
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              cartItem.item.images[0].fullHDImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    // child: InkWell(
                    //   onTap: () {
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return FullScreenDialog(
                    //           images: widget.images,
                    //           initialImage: image,
                    //         );
                    //       },
                    //     );
                    //   },
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(8.0),
                    //     child: AspectRatio(
                    //       aspectRatio: 1,
                    //       child: Image.network(
                    //         cartItem.item.images[0].fullHDImage,
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      PriceWidget(
                        price: cartItem.item.price,
                        discount: cartItem.item.discount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الحجم'),
                    Text(cartItem.size),
                  ],
                ),
                Column(
                  children: [
                    qtyWidget(cartItem),
                    const SizedBox(height: 8),
                    Text('(${cartItem.totalPrice}) $currency'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget hCard(InvoiceItem cartItem) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 256),
      child: Builder(
        builder: (context) {
          final size = MediaQuery.of(context).size;
          return Card(
            child: Row(
              children: [
                SizedBox(
                  width: 0.25 * size.width,
                  child: Image.network(cartItem.item.images[0].fullHDImage),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 70, child: Text('الإسم')),
                            const Text(':   '),
                            Text(cartItem.item.name, maxLines: 5),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 70, child: Text('الحجم')),
                            const Text(':   '),
                            Text(cartItem.size),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 70, child: Text('سعر الوحدة')),
                            const Text(':   '),
                            PriceWidget(price: cartItem.item.price, discount: cartItem.item.discount),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 70, child: Text('الكمية')),
                            const Text(':   '),
                            qtyWidget(cartItem),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 70, child: Text('الإجمالي')),
                            const Text(':   '),
                            PriceWidget(price: cartItem.originalPrice, discount: cartItem.totalDiscount),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget qtyWidget(InvoiceItem cartItem) {
    return Consumer(
      builder: (context, ref, widget) {
        return Row(
          children: [
            IconButton(
              onPressed: () {
                ref.read(CartNotifier.itemsProvider.notifier).addItem(cartItem.copyWith(quantity: 1));
              },
              icon: const Icon(Icons.add),
            ),
            Text('(${cartItem.quantity})'),
            IconButton(
              onPressed: () {
                if (cartItem.quantity == 1) {
                  removeItemConfirmationDialog(context, ref, cartItem);
                } else {
                  ref.read(CartNotifier.itemsProvider.notifier).removeItem(cartItem.copyWith(quantity: 1));
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
    InvoiceItem cartItem,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('هل أنت متأكد من أنك تريد حذف هذا العنصر؟'),
          content: Text(cartItem.item.name),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref.read(CartNotifier.itemsProvider.notifier).removeItem(cartItem);
                Navigator.pop(context);
              },
              child: const Text('نعم'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لا'),
            ),
          ],
        );
      },
    );
  }

  double total(Iterable<InvoiceItem> invoiceItems) {
    var total = 0.0;
    for (final cartItem in invoiceItems) {
      total += cartItem.totalPrice;
    }
    return total;
  }
}
