import 'package:arabiya/models/item.dart';
import 'package:arabiya/models/cart_item.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'full_screen_dialog.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  final sizeProvider = StateProvider<String?>((ref) => null);

  ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            children: [
              if (item.images.isNotEmpty) ImageCarousel(images: item.images),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/item/${item.id}',
                        arguments: item,
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                  ),
                ],
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('الحجم'),
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
              const Spacer(),
              footer(),
            ],
          ),
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

class ImageCarousel extends StatefulWidget {
  final List<ArabiyaImages> images;

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
              //fullHD are keys
              for (final image in widget.images)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FullScreenDialog(
                          images: widget.images,
                          initialImage: image,
                        );
                      },
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: image.fullHDImage,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => Stack(
                      alignment: Alignment.center,
                      children: [
                        IntrinsicHeight(
                          child: CachedNetworkImage(
                            imageUrl: image.thumbImage,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                )
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
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 36,
              width: constraints.maxWidth,
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.images.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final image = widget.images.elementAt(index);
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(index),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: _getIndicatorSize(index),
                          child: Padding(
                            padding: EdgeInsets.all(index == _current ? 2 : 1),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                image.thumbImage,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  double _getIndicatorSize(int index) {
    return index == _current ? 16 : 12;
  }
}
