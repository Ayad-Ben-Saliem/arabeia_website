import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/cart_item.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:arabiya/ui/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemPage extends StatelessWidget {
  final String? id;
  final Item? item;

  const ItemPage({
    Key? key,
    this.id,
    this.item,
  }) : assert(id != null || item != null);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(
        builder: (context) {
          if (item != null) return ItemView(item: item!);
          return Center(
            child: FutureBuilder<Item?>(
              future: Database.getItem(id!),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return ItemView(item: snapshot.requireData!);
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('Error!! ${snapshot.error}');
              },
            ),
          );
        },
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  final Item item;

  ItemView({super.key, required this.item});

  final sizeProvider = StateProvider<String?>((ref) => null);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight,
              maxWidth: 720,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.images.isNotEmpty) ImageCarousel(images: item.images),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                if (item.description?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      item.description!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'الحجم',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: [
                      for (final size in item.sizes)
                        Consumer(
                          builder: (context, ref, widget) {
                            final selected = size == ref.watch(sizeProvider);
                            return ActionChip(
                              label: Text(
                                size,
                                style: TextStyle(
                                  color: selected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              backgroundColor: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              onPressed: () {
                                ref.read(sizeProvider.notifier).state = size;
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(),
                footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget footer() {
    return Row(
      children: [
        const SizedBox(width: 8),
        priceWidget(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: (ref.watch(sizeProvider) != null)
                    ? () =>
                        ref.read(CartNotifier.itemsProvider.notifier).addItem(
                              CartItem(
                                item: item,
                                size: ref.read(sizeProvider)!,
                                quantity: 1,
                              ),
                            )
                    : null,
                child: const Text('إضافة للسلة'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget priceWidget() {
    if (item.discount != null) {
      return Column(
        children: [
          Text(
            '${item.price} $currency',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '${item.effectivePrice} $currency',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      );
    } else {
      return Text(
        '${item.price} $currency',
        style: const TextStyle(fontSize: 18),
      );
    }
  }
}
