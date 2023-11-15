import 'dart:async';
import 'dart:convert';

import 'package:arabiya/db/db.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentWidget = StateProvider<Widget>((ref) => Container());

final _currentChangedOutside = StateProvider((ref) => 0);

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 256),
            child: Consumer(
              builder: (context, ref, child) {
                return ListView(
                  children: [
                    ListTile(
                      title: const Text('Items'),
                      onTap: () {
                        ref.read(currentWidget.notifier).state =
                            const ItemsView();
                      },
                    ),
                    ListTile(
                      title: const Text('Home Page'),
                      onTap: () {
                        ref.read(currentWidget.notifier).state =
                            const HomePageView();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const VerticalDivider(width: 0),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) => ref.watch(currentWidget),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Items'));
  }
}

final _originalHomePage = StateProvider((ref) => '');

final _currentHomePage = StateProvider((ref) => ref.watch(_originalHomePage));

class _JsonError {
  final FormatException exception;
  final StackTrace stackTrace;

  _JsonError(this.exception, this.stackTrace);
}

final _jsonError = StateProvider<_JsonError?>((ref) => null);

final _canSave = StateProvider(
  (ref) {
    if (ref.watch(_jsonError) == null) {
      if (ref.watch(currentWidget) is HomePageView) {
        try {
          final originalData = json.decode(ref.watch(_originalHomePage));
          final currentData = json.decode(ref.watch(_currentHomePage));
          return json.encode(originalData) != json.encode(currentData);
        } on FormatException catch (e) {}
      } else if (ref.watch(currentWidget) is ItemsView) {}
    }
    return false;
  },
);

class HomePageView extends ConsumerWidget {
  const HomePageView({super.key});

  @override
  Widget build(context, ref) {
    var timer = Timer(const Duration(milliseconds: 100), () {});
    final controller = TextEditingController();

    return FutureBuilder(
      future: Database.getHomePageData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final data = Utils.getPrettyString(snapshot.requireData);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(_originalHomePage.notifier).state = data;
          });
          controller.text = data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Consumer(
                      builder: (context, ref, child) {
                        if (ref.watch(_currentChangedOutside) > 0) {
                          controller.text = ref.read(_currentHomePage);
                        }

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
                          maxLines: null,
                          // maxLines: 0xffff,
                          autofocus: true,
                          onChanged: (txt) {
                            if (timer.isActive) timer.cancel();
                            timer = Timer(
                              const Duration(milliseconds: 100),
                              () {
                                ref.read(_currentHomePage.notifier).state = txt;
                                try {
                                  json.decode(txt);

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
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final notifier = ref.read(_currentHomePage.notifier);
                        try {
                          final data = json.decode(notifier.state);
                          notifier.state = Utils.getPrettyString(data);
                          ref.read(_currentChangedOutside.notifier).state++;
                        } on FormatException catch (e) {}
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          return ElevatedButton(
                            onPressed: ref.watch(_canSave)
                                ? () {
                                    final txtData = ref.read(_currentHomePage);
                                    final data = json.decode(txtData);
                                    Database.updateHomePageData(data);
                                    ref.read(_originalHomePage.notifier).state =
                                        ref.read(_currentHomePage);
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const _SuccessDialog(),
                                    );
                                  }
                                : null,
                            child: const Text('رفع'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              child: Text('تمت العملية بنجاح'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Center(
                        child: Text(
                          'متابعة التعديل',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      ),
                      child: const Center(
                        child: Text(
                          'عودة للصفحة الرئيسية',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
