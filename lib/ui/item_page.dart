import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/widgets/custom_indicator.dart';
import 'package:arabiya/ui/widgets/item_view.dart';
import 'package:flutter/material.dart';


class ItemPage extends StatelessWidget {
  final String? id;
  final Item? item;

  const ItemPage({
    super.key,
    this.id,
    this.item,
  }) : assert(id != null || item != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight, maxWidth: 720),
                child: Builder(
                  builder: (context) {
                    if (item != null) return ItemView(item: item!);
                    return Center(
                      child: FutureBuilder<Item?>(
                        future: Database.getItem(id!),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              return ItemView(item: snapshot.requireData!);
                            }
                          } else if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CustomIndicator();
                          }
                          return Text('Error!! ${snapshot.error}');
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}