


import 'package:arabiya/models/item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final zoomStateProvider = StateProvider<double>((ref) => 1.0);
final showZoomTools = StateProvider<bool>((ref) => false);

final currentImage = StateProvider((ref) => const ArabiyaImages('', ''));



class FullScreenImageDialog extends ConsumerWidget {
  final List<ArabiyaImages> images;
  final ArabiyaImages initialImage;

  const FullScreenImageDialog({
    super.key,
    required this.images,
    required this.initialImage,
  });

  @override
  Widget build(context, ref) {
    final isToggleOn = ref.watch(showZoomTools.notifier).state;

    final zoomScale = ref.watch(zoomStateProvider);


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(currentImage.notifier).state = initialImage;
    });
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              return Align(
                alignment: Alignment.center,
                child: Stack(
                    children: [
                      GestureDetector(
                        onTap:(){

                          ref.refresh(showZoomTools.notifier).state = true;
              },
                        onDoubleTap: () {
                          final zoomState = ref.read(zoomStateProvider.notifier);
                          zoomState.state = (zoomState.state == 1.0) ? 2.0 : 1.0;
                        },
                        child: InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.5,
                          maxScale: 4.0,
                          scaleEnabled: true,
                          panEnabled: true,
                          transformationController: TransformationController()
                            ..value = Matrix4.diagonal3Values(zoomScale, zoomScale, 1),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: ref.watch(currentImage).fullHDImage,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (zoomScale != 1.0 && ref.read(showZoomTools.notifier).state == true)
                        Positioned(
                          top: 50.0,
                          left: 8,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.zoomIn,
                            child: IconButton(
                              icon: const Icon(Icons.zoom_out),
                              onPressed: () {
                                final zoomState = ref.read(zoomStateProvider.notifier);
                                zoomState.state = zoomState.state - 0.5;
                              },
                            ),
                          ),
                        ),
                      if (zoomScale < 4.0 && ref.read(showZoomTools.notifier).state == true)
                        Positioned(
                          top: 8.0,
                          left: 8,
                          child: IconButton(
                            icon: const Icon(Icons.zoom_in),
                            onPressed: () {
                              final zoomState = ref.read(zoomStateProvider.notifier);
                              zoomState.state = zoomState.state + 0.5;
                            },
                          ),
                        ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            Navigator.pop(context);
                            ref.read(zoomStateProvider.notifier).state = 1.0;
                            ref.refresh(showZoomTools.notifier).state = false;
                          },
                        ),
                      ),
                    ]
                ),
              );
            }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              children: [
                for (final image in images)
                  GestureDetector(
                      onTap: () {
                       ref.read(currentImage.notifier).state = image;
                        ref.read(zoomStateProvider.notifier).state = 1.0;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey,width: 2)
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                imageUrl: image.thumbImage,
                                fit: BoxFit.cover,
                              ),
                            )),
                      ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
