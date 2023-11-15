import 'package:arabiya/models/item.dart';
import 'package:arabiya/ui/widgets/item_card.dart';
import 'package:flutter/material.dart';

class ItemsGridView extends StatelessWidget {
  final Iterable<Item> items;

  const ItemsGridView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount(BoxConstraints constraints) {
          return (constraints.maxWidth / 500).ceil();
        }

        double aspectRatio(BoxConstraints constraints) {
          final width = constraints.maxWidth / crossAxisCount(constraints);

          // image carousel + carousel indicators + name and footer
          // final height = width / (16 / 9) + 36 + 128 + 118;
          final height = width / (16 / 9) + 36 + 128 + 128;
          return width / height;
        }

        return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount(constraints),
              childAspectRatio: aspectRatio(constraints),
            ),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: items.map((e) => ItemCard(item: e)).toList());
      },
    );
  }
}
