import 'package:arabiya/models/item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

final currentImage = StateProvider((ref) => const ArabiyaImages('', ''));

ValueNotifier<double> scaleNotifier = ValueNotifier<double>(50.0);

class FullScreenDialog extends ConsumerStatefulWidget {
  final List<ArabiyaImages> images;
  final ArabiyaImages initialImage;

  const FullScreenDialog({
    super.key,
    required this.images,
    required this.initialImage,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FullScreenDialogState();
  }
}

class _FullScreenDialogState extends ConsumerState<FullScreenDialog> {
  double scaleBarSize = 100.0;
  late PhotoViewController controller;

  @override
  void initState() {
    super.initState();
    controller = PhotoViewController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(currentImage.notifier).state = widget.initialImage;
    });
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Consumer(builder: (context, ref, child) {
                    return PhotoView(
                      imageProvider:
                          NetworkImage(ref.watch(currentImage).fullHDImage),
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                      controller: controller,
                      scaleStateChangedCallback: (scaleState) {
                        double scale = scaleBarSize / 100.0;
                        controller.scale = scale;
                      },
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 180.0),
                        child: Column(children: [
                          ValueListenableBuilder(
                            valueListenable: scaleNotifier,
                            builder: (BuildContext context, double scale,
                                Widget? child) {
                              return Slider(
                                value: scale,
                                min: 50.0,
                                max: 200.0,
                                divisions: 15,
                                onChanged: (double value) {
                                  scaleNotifier.value = value;
                                  controller.scale = value / 100.0;
                                },
                              );
                            },
                          ),
                        ])),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        scaleNotifier.value = 50;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              children: [
                for (final image in widget.images)
                  InkWell(
                      onTap: () {
                        scaleNotifier.value = 50;
                        controller.scale = scaleNotifier.value / 100.0;
                        ref.read(currentImage.notifier).state = image;
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                               Container(
                                width: _getSize(image),
                                height: _getSize(image),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey, width: 2)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: image.thumbImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                           ))
              ],
            ),
          ),
        ],
      ),
    );
  }
  double _getSize(ArabiyaImages image) {
    return image == ref.read(currentImage.notifier).state ? 60 : 50;
  }
}
