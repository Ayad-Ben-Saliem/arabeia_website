import 'dart:async';

import 'package:arabeia_website/ui/cart_notifier.dart';
import 'package:arabeia_website/ui/cart_page.dart';
import 'package:arabeia_website/ui/widgets/item_card.dart';
import 'package:badges/badges.dart' as badges;
import 'package:arabeia_website/db/db.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const currency = 'د.ل';

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
                    return Center(child: Text('${snapshot.error}'));
                  }

                  if (snapshot.data == null) {
                    return const Center(child: Text('No data!!!'));
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
                        // todo comment this out and check the result
                        physics: const ClampingScrollPhysics(),
                        children: [
                          for (final item in items) ItemCard(item: item)
                        ],
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
                        onPressed: ref.watch(CartNotifier.itemsProvider).isNotEmpty
                            ? cartPage(context)
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
                                    position: badges.BadgePosition.topStart(
                                      start: 32,
                                      top: -2,
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
                                      '${ref.watch(CartNotifier.itemsProvider).length}',
                                      style: TextStyle(
                                        color: ref.watch(darkMode)
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    child: const Icon(
                                        Icons.shopping_cart_outlined),
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

  VoidCallback cartPage(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    };
  }
}

