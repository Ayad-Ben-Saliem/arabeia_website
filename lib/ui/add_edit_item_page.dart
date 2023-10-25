import 'dart:async';
import 'dart:convert';

import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _currentItem = StateProvider(
  (ref) => const Item(name: '', sizes: [], images: [], images2: {}, price: 0.0),
);

class AddEditItemPage extends ConsumerWidget {
  final Item? item;
  final String? id;

  const AddEditItemPage({super.key, this.item, this.id});

  @override
  Widget build(context, ref) {
    if (item != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => ref.read(_currentItem.notifier).state = item!,
      );
      return const _AddEditItemPage();
    } else if (id != null) {
      return FutureBuilder<Item?>(
        future: Database.getItem(id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ref.read(_currentItem.notifier).state = snapshot.requireData!;
              return const _AddEditItemPage();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return Text(
            'Error!! ${snapshot.error}',

          );
        },
      );
    } else {
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
    Timer timer = Timer(
      const Duration(milliseconds: 100),
      () {},
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer(
        builder: (context, ref, child) {
          final currentItem = ref.read(_currentItem);
          return TextField(
            controller: TextEditingController(
              text: Utils.getPrettyString(currentItem.toJson),
            ),
            decoration: const InputDecoration(border: InputBorder.none),
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
                  } catch (e) {
                    // TODO: show an error
                    print(e);
                  }
                },
              );
            },
          );
        },
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
                        onPressed: () {},
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
