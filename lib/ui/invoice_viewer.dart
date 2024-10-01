import 'package:arabiya/pdf/reporting.dart';
import 'package:arabiya/ui/app.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/material.dart';
import 'package:arabiya/models/invoice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoiceViewer extends StatelessWidget {
  final Invoice invoice;

  const InvoiceViewer({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final EdgeInsets padding;
    if (ScreenType.type(context) == ScreenType.small) {
      padding = const EdgeInsets.all(16);
    } else {
      padding = EdgeInsets.symmetric(horizontal: size.width / 50, vertical: 24);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipientInfo(),
            const Divider(height: 16),
            _buildInvoiceItems(context),
            const Divider(height: 16),
            _buildTotalAmount(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientInfo() {
    const style = TextStyle(fontSize: 18);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width;
        // Use LayoutBuilder to decide the layout based on available width
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اسم الزبون', style: style, overflow: TextOverflow.ellipsis),
                        Text('رقم الهاتف', style: style, overflow: TextOverflow.ellipsis),
                        Text('العنوان', style: style, overflow: TextOverflow.ellipsis),
                        Text('التاريخ', style: style, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' : ', style: style, overflow: TextOverflow.ellipsis),
                        Text(' : ', style: style, overflow: TextOverflow.ellipsis),
                        Text(' : ', style: style, overflow: TextOverflow.ellipsis),
                        Text(' : ', style: style, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.recipientName,
                          style: style,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(invoice.recipientPhone, style: style, overflow: TextOverflow.ellipsis),
                        Text(invoice.recipientAddress, style: style, overflow: TextOverflow.ellipsis),
                        Text(Reporting.format(invoice.createAt), style: style, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (width > 400)
              SizedBox(
                width: 75,
                height: 75,
                child: Consumer(
                  builder: (context, ref, child) {
                    try {
                      return ref.watch(mode) != Mode.dark ? Image.asset('images/logo.webp') : Image.asset('images/white_logo.webp');
                    } catch (e) {
                      return Wrap(
                        children: [
                          Text('${const Icon(Icons.error_outline)} | Error: $e'),
                        ],
                      );
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceItems(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _itemsList();
        } else {
          return _itemsTable();
        }
      },
    );
  }

  Widget _itemsTable() {
    const boldFontStyle = TextStyle(fontWeight: FontWeight.bold);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 0.50 * constraints.maxWidth),
                    child: const Center(child: Text('الصنف', style: boldFontStyle, overflow: TextOverflow.ellipsis)),
                  ),
                ),
                const DataColumn(label: Center(child: Text('الحجم', style: boldFontStyle, overflow: TextOverflow.ellipsis))),
                const DataColumn(label: Center(child: Text('الكمية', style: boldFontStyle, overflow: TextOverflow.ellipsis)), numeric: true),
                const DataColumn(label: Center(child: Text('السعر', style: boldFontStyle, overflow: TextOverflow.ellipsis)), numeric: true),
                const DataColumn(label: Center(child: Text('المجموع', style: boldFontStyle, overflow: TextOverflow.ellipsis)), numeric: true),
              ],
              rows: [
                for (final item in invoice.invoiceItems)
                  DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 0.50 * constraints.maxWidth,
                          child: Text(item.item.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Text(item.size, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Text(item.quantity.toString(), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: PriceWidget(
                            price: item.item.price,
                            discount: item.item.discount,
                            direction: Axis.vertical,
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Text('${item.totalPrice} $currency', overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _itemsList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أصناف الفاتورة:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            for (final indexedItem in invoice.invoiceItems.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indexedItem.$2.item.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'الحجم:',
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          indexedItem.$2.size,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'الكمية:',
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${indexedItem.$2.quantity}x',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (indexedItem.$2.item.discountedPrice < indexedItem.$2.item.price) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'السعر قبل التخفيض:',
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${indexedItem.$2.item.price.toStringAsFixed(2)} $currency',
                            style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'السعر بعد التخفيض:',
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${indexedItem.$2.item.discountedPrice.toStringAsFixed(2)} $currency',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'السعر:',
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${indexedItem.$2.item.price.toStringAsFixed(2)} $currency',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'إجمالي السعر:',
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${indexedItem.$2.totalPrice.toStringAsFixed(2)} $currency',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (indexedItem.$1 != invoice.invoiceItems.length - 1) const Divider(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'الإجمالي:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${readableMoney(invoice.total)} $currency',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (invoice.savings > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'لقد قمت بتوفير:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${readableMoney(invoice.savings)} $currency',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class PriceWidget extends StatelessWidget {
  final double price;
  final double? discount;
  final Axis direction;

  final TextStyle? style;

  const PriceWidget({
    super.key,
    required this.price,
    this.discount,
    this.style,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        if (isDiscounted)
          Text(
            '${readableMoney(price)}${isVertical ? ' $currency' : ''}',
            style: _style.copyWith(
              decoration: style?.decoration ?? TextDecoration.lineThrough,
              color: style?.color ?? Colors.red,
            ),
          ),
        if (isDiscounted && isHorizontal) const SizedBox(width: 8),
        Text(
          '${readableMoney(price - (discount ?? 0))} $currency',
          style: _style.copyWith(
            fontWeight: style?.fontWeight ?? FontWeight.bold,
            color: isDiscounted ? style?.color ?? Colors.green : null,
          ),
        ),
      ],
    );
  }

  bool get isDiscounted => discount != null && discount! > 0;

  bool get isVertical => direction == Axis.vertical;

  bool get isHorizontal => direction == Axis.horizontal;

  TextStyle get _style => style ?? const TextStyle();
}
