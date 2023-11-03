import 'dart:async';
import 'dart:convert';

import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_image.dart';

const _emptyItem = Item(
  name: '',
  sizes: [],
  images: [],
  images2: {},
  price: 0.0,
);

final _originalItem = StateProvider((ref) => _emptyItem);

final _currentItem = StateProvider((ref) => ref.watch(_originalItem));

class _JsonError {
  final FormatException exception;
  final StackTrace stackTrace;

  _JsonError(this.exception, this.stackTrace);
}

final _jsonError = StateProvider<_JsonError?>((ref) => null);

final _canSave = StateProvider(
  (ref) {
    return ref.watch(_originalItem) != ref.watch(_currentItem) &&
        ref.watch(_jsonError) == null;
  },
);

class AddEditItemPage extends ConsumerWidget {
  final Item? item;
  final String? id;

  const AddEditItemPage({super.key, this.item, this.id});

  @override
  Widget build(context, ref) {
    // _jsonError need to be reset to remove previous state if set.
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => ref.read(_jsonError.notifier).state = null,
    );

    if (item != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => ref.read(_originalItem.notifier).state = item!,
      );
      return const _AddEditItemPage();
    } else if (id != null) {
      return FutureBuilder<Item?>(
        future: Database.getItem(id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ref.read(_originalItem.notifier).state = snapshot.requireData!;
              return const _AddEditItemPage();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return Text('Error!! ${snapshot.error}');
        },
      );
    } else {
      // Ensure that _original item is _emptyItem
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => ref.read(_originalItem.notifier).state = _emptyItem,
      );
      return const _AddEditItemPage();
    }
  }
}

class _AddEditItemPage extends StatelessWidget {
  const _AddEditItemPage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Consumer(builder: (context, ref, child) {
              return IconButton(
                onPressed: ref.watch(_canSave)
                    ? () => Database.addUpdateItem(ref.read(_currentItem))
                    : null,
                icon: const Icon(Icons.check),
              );
            }),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'JSON'),
              Tab(text: 'Visual'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _JsonFormItem(),
            _VisualFormItem(),
          ],
        ),
      ),
    );
  }
}

class _JsonFormItem extends StatelessWidget {
  const _JsonFormItem();

  @override
  Widget build(BuildContext context) {
    Timer timer = Timer(const Duration(milliseconds: 100), () {});

    final controller = TextEditingController();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final selection = controller.selection;
            controller.text = Utils.getPrettyString(
              ref.watch(_currentItem).toJson,
            );
            try {
              controller.selection = selection;
            } catch (e) {
              // Sometimes error happened
            }
            return Consumer(
              builder: (context, ref, child) {
                return TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: ref.watch(_jsonError) == null
                        ? Colors.transparent
                        : Colors.red.shade50,
                  ),
                  scrollPadding: const EdgeInsets.all(8.0),
                  keyboardType: TextInputType.multiline,
                  maxLines: 0xffff,
                  autofocus: true,
                  onChanged: (txt) {
                    if (timer.isActive) timer.cancel();
                    timer = Timer(
                      const Duration(milliseconds: 100),
                      () {
                        try {
                          final currentItem = Item.fromJson(json.decode(txt));
                          ref.read(_currentItem.notifier).state = currentItem;

                          // Reset _jsonError
                          ref.read(_jsonError.notifier).state = null;
                        } on FormatException catch (exception, stackTrace) {
                          ref.read(_jsonError.notifier).state =
                              _JsonError(exception, stackTrace);
                          print(exception);
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VisualFormItem extends StatelessWidget {
  const _VisualFormItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: 128,
            child: Consumer(
              builder: (context, ref, child) {
                final images = ref.watch(
                  _currentItem.select((item) => item.images),
                );
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var image in images)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(image),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> AddImage()));
                          
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer(
            builder: (context, ref, child) {
              return TextField(
                controller: TextEditingController(
                  text: ref.read(_currentItem.select((item) => item.name)),
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'الإسم',
                ),
                onChanged: (txt) {
                  final currentItem = ref.read(_currentItem);
                  ref.read(_currentItem.notifier).state = currentItem.copyWith(
                    name: txt,
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer(
            builder: (context, ref, child) {
              return TextField(
                controller: TextEditingController(
                  text: ref.read(
                    _currentItem.select((item) => item.description),
                  ),
                ),
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'الوصف',
                  alignLabelWithHint: true,
                ),
                onChanged: (txt) {
                  final currentItem = ref.read(_currentItem);
                  ref.read(_currentItem.notifier).state = currentItem.copyWith(
                    description: txt,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
