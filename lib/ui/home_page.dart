import 'package:arabiya/main.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/widgets/custom_indicator.dart';
import 'package:arabiya/utils.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/widgets/items_grid_view.dart';
import 'package:arabiya/ui/widgets/link_text.dart';
import 'package:badges/badges.dart' as badges;
import 'package:arabiya/db/db.dart';
import 'package:arabiya/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartCount = StateProvider((ref) {
  final items = ref.watch(CartNotifier.itemsProvider);
  int count = 0;
  for (var item in items) {
    count += item.quantity;
  }
  return count;
});

final searchText = StateProvider<String>((ref) => '');

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      drawer: drawer(context),
      body: body(),
    );
  }

  PreferredSizeWidget appbar() {
    return AppBar(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512, maxHeight: 50),
        child: Consumer(
          builder: (context, ref, child) {
            return SearchBar(
              hintText: 'بحث',
              // shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              leading: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              onChanged: (value) => ref.read(searchText.notifier).state = value,
            );
          },
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ClipRRect(
            child: Image.asset('images/white_logo.webp'),
          ),
        ),
      ],
    );
  }

  Widget body() {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: Database.getHomePageItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.active) {
                return const CustomIndicator();
              }
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  if (snapshot.data == null) {
                    return const Center(child: Text('لا توجد بيانات!!!'));
                  }

                  return Consumer(
                    builder: (context, ref, child) {
                      final filteredItems = filter(snapshot.requireData, ref.watch(searchText));

                      if (filteredItems.isEmpty) {
                        return const Center(child: Text('لا توجد نتائج مطابقة!!!'));
                      }

                      return ItemsGridView(items: filteredItems);
                    },
                  );
                }
              }
              return Container();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer(
            builder: (context, ref, widget) {
              return ElevatedButton(
                onPressed: ref.watch(CartNotifier.itemsProvider).isNotEmpty ? () => Navigator.pushNamed(context, '/cart') : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('سلة المشتريات'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer(
                        builder: (context, ref, widget) {
                          return badges.Badge(
                            position: badges.BadgePosition.custom(
                              start: 30,
                              top: -3,
                            ),
                            badgeAnimation: const badges.BadgeAnimation.scale(
                              disappearanceFadeAnimationDuration: Duration(milliseconds: 100),
                              curve: Curves.easeInCubic,
                            ),
                            showBadge: true,
                            badgeStyle: badges.BadgeStyle(badgeColor: ref.watch(mode) == Mode.dark ? Colors.black : Colors.white),
                            badgeContent: Text(
                              '${ref.watch(cartCount)}',
                              style: TextStyle(color: ref.watch(mode) == Mode.dark ? Colors.white : Colors.black),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                            ),
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
      ],
    );
  }
}

Widget drawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('الصفحة الرئيسية'),
                onTap: () => Navigator.popAndPushNamed(context, '/'),
              ),
              ListTile(
                onTap: () => Navigator.popAndPushNamed(context, '/items'),
                title: const Text('إعدادات الأصناف'),
              ),
              ListTile(
                onTap: () => Navigator.popAndPushNamed(context, '/invoices'),
                title: const Text('الفواتير'),
              ),
              ListTile(
                onTap: () => Navigator.popAndPushNamed(context, '/appearance'),
                title: const Text('إعدادات المظهر'),
              ),
              ListTile(
                onTap: () => Navigator.popAndPushNamed(context, '/reports'),
                title: const Text('التقارير'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            return ListTile(
              onTap: () {
                final Mode value = ref.read(mode) == Mode.dark ? Mode.light : Mode.dark;
                ref.read(mode.notifier).state = value;
                sharedPreferences.setString('mode', '$value');
              },
              title: Tooltip(
                message: 'اضغط لتغيير نمط الألوان',
                child: Text(ref.watch(mode) == Mode.light ? 'فاتح' : 'داكن'),
              ),
              trailing: Icon(ref.watch(mode) == Mode.light ? Icons.light_mode : Icons.dark_mode),
            );
          },
        ),
        LinkText('Powered by Manassa Ltd.', url: 'https://manassa.ly'),
        const SizedBox(height: 8),
      ],
    ),
  );
}

Iterable<Item> filter(Iterable<Item> items, String searchText) {
  return items.where((item) {
    return searchText.containEachOtherIgnoreCase(item.name);
  }).toList();
}
