import 'package:arabiya/models/item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

final currentImage = StateProvider(
  (ref) => const ArabiyaImages(
    thumbImage: 'https://i.postimg.cc/bd3c6dQ9/Arabeia-Logo-2.jpg',
    fullHDImage: 'https://i.postimg.cc/Gh1LmytV/Arabeia-Logo-2.jpg',
  ),
);

final controller = AutoDisposeProvider((ref) => PhotoViewController());

class FullScreenDialog extends ConsumerWidget {
  final List<ArabiyaImages> images;
  final ArabiyaImages initialImage;

  const FullScreenDialog({
    super.key,
    required this.images,
    required this.initialImage,
  });

  @override
  Widget build(context, ref) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(currentImage.notifier).state = initialImage;
    });

    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    return PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                        ref.watch(currentImage).fullHDImage,
                      ),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      controller: ref.read(controller),
                    );
                  }
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              return Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (final image in images)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          ref.read(currentImage.notifier).state = image;
                          ref.read(controller).scale = 1;
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _getColor(ref, image),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: image.thumbImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getColor(WidgetRef ref, ArabiyaImages image) {
    return image == ref.watch(currentImage) ? Colors.red : Colors.grey;
  }
}
