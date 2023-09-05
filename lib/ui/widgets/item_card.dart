import 'package:arabeia_website/models/cart_item.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/ui/cart_notifier.dart';
import 'package:arabeia_website/ui/home_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  final sizeProvider = StateProvider<String?>((ref) => null);

  ItemCard({super.key, required this.item});

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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('الحجم'),
            ),
          ),
          Wrap(
            children: [
              for (final size in item.sizes)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Consumer(
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
                ),
            ],
          ),
          const Spacer(),
          footer(),
        ],
      ),
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
                    ? () => ref.read(CartNotifier.itemsProvider.notifier).addItem(
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
            style: const TextStyle(
              fontSize: 18,
            ),
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
