import 'dart:async';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/widgets/item_card.dart';
import 'package:badges/badges.dart' as badges;
import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const currency = 'د.ل';

final cartCount = StateProvider((ref) {
  final items = ref.watch(CartNotifier.itemsProvider);
  int count = 0;
  for (var item in items) {
    count += item.quantity;
  }
  return count;
});

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final getItemsFuture = Database.getItems();
    final getItemsCompleter = Completer<Iterable<Item>>();
    getItemsFuture
        .then(getItemsCompleter.complete)
        .catchError(getItemsCompleter.completeError);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          flexibleSpace: Container(
            color: Colors.grey[300],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'نسخة تجريبية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: getItemsFuture,
                builder: (context, snapshot) {
                  if (!getItemsCompleter.isCompleted) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  }

                  if (snapshot.data == null) {
                    return const Center(
                      child: Text('لا توجد بيانات!!!'),
                    );
                  }

                   final items = snapshot.data!;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount(BoxConstraints constraints) {
                        return (constraints.maxWidth / 500).ceil();
                      }

                      double aspectRatio(BoxConstraints constraints) {
                        final width =
                            constraints.maxWidth / crossAxisCount(constraints);

                        // image carousel + carousel indicators + name and footer
                        // final height = width / (16 / 9) + 36 + 128 + 118;
                        final height = width / (16 / 9) + 36 + 128 + 128;
                        return width / height;
                      }

                      return GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount(constraints),
                          childAspectRatio: aspectRatio(constraints),
                        ),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: items.map((e) => ItemCard(item: e)).toList()
                      );
                    },
                  );
                }),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer(
                    builder: (context, ref, widget) {
                      return ElevatedButton(
                        onPressed:
                            ref.watch(CartNotifier.itemsProvider).isNotEmpty
                                ? () => Navigator.pushNamed(context, '/cart')
                                : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('سلة المشتريات'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Consumer(
                                builder: (context, ref, widget) {
                                  return badges.Badge(
                                    position: badges.BadgePosition.custom(
                                      start: 30,
                                      top: -3,
                                    ),
                                    badgeAnimation:
                                        const badges.BadgeAnimation.scale(
                                      disappearanceFadeAnimationDuration:
                                          Duration(milliseconds: 100),
                                      curve: Curves.easeInCubic,
                                    ),
                                    showBadge: true,
                                    badgeStyle: badges.BadgeStyle(
                                      badgeColor: ref.watch(darkMode)
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    badgeContent: Text(
                                      '${ref.watch(cartCount)}',
                                      style: TextStyle(
                                        color: ref.watch(darkMode)
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // floatingActionButton: Consumer(
      //   builder: (context, ref, child) {
      //     return IconButton(
      //       onPressed: () => ref.read(darkMode.notifier).state = !ref.read(darkMode),
      //       icon: const Icon(Icons.dark_mode_outlined),
      //     );
      //   },
      // ),
    );
  }
}
