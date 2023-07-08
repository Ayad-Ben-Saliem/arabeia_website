import 'dart:async';

import 'package:arabeia_website/ui/cart_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:arabeia_website/db/db.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/ui/app.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
                        final height = width / (16 / 9) + 36 + 118;
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
                        onPressed: ref.watch(CartItems.provider).isNotEmpty
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
                                      '${ref.watch(CartItems.provider).length}',
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

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          if (item.images.isNotEmpty) ImageCarousel(images: item.images),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const SizedBox(width: 8),
              if (item.discount != null)
                Column(
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
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '${item.price} $currency',
                  style: const TextStyle(fontSize: 18),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () =>
                          ref.read(CartItems.provider.notifier).addItem(item),
                      child: const Text('إضافة للسلة'),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({super.key, required this.images});

  @override
  State<StatefulWidget> createState() {
    return _ImageCarouselState();
  }
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;

  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: CarouselSlider(
            items: [
              for (final image in widget.images)
                Image.network(image, fit: BoxFit.fill),
              // FadeInImage.memoryNetwork(
              //   placeholder: placeholder,
              //   image: image,
              //   fit: BoxFit.fill,
              // )
            ],
            carouselController: _controller,
            options: CarouselOptions(
              enlargeCenterPage: true,
              viewportFraction: 1,
              onPageChanged: (index, reason) =>
                  setState(() => _current = index),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: _getIndicatorSize(entry.key),
                    child: Padding(
                      padding: EdgeInsets.all(entry.key == _current ? 2 : 1),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(entry.value),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _getIndicatorSize(int index) {
    return index == _current ? 16 : 12;
  }
}
