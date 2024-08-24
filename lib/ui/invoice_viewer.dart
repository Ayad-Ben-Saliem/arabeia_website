import 'package:arabiya/pdf/reporting.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/material.dart';
import 'package:arabiya/models/invoice.dart';

class InvoiceViewer extends StatelessWidget {
  final Invoice invoice;

  const InvoiceViewer({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final EdgeInsets padding;
    if (DeviceType.isPhone(context)) {
      padding = const EdgeInsets.all(8);
    } else {
      padding = EdgeInsets.symmetric(horizontal: size.width / 10, vertical: 24);
    }

    return SingleChildScrollView(
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
    return Row(
      children: [
        const SizedBox(
          width: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم الزبون', style: style),
              Text('رقم الهاتف', style: style),
              Text('العنوان', style: style),
              Text('التاريخ', style: style),
            ],
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(' : ', style: style),
            Text(' : ', style: style),
            Text(' : ', style: style),
            Text(' : ', style: style),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.recipientName, style: style),
            Text(invoice.recipientPhone, style: style),
            Text(invoice.recipientAddress, style: style),
            Text(Reporting.format(invoice.createAt), style: style),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceItems(BuildContext context) {
    if (DeviceType.isPhone(context)) return _itemsList();

    return _itemsTable();
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
                    child: const Center(child: Text('الصنف', style: boldFontStyle)),
                  ),
                ),
                const DataColumn(label: Center(child: Text('الحجم', style: boldFontStyle))),
                const DataColumn(label: Center(child: Text('الكمية', style: boldFontStyle)), numeric: true),
                const DataColumn(label: Center(child: Text('السعر', style: boldFontStyle)), numeric: true),
                const DataColumn(label: Center(child: Text('المجموع', style: boldFontStyle)), numeric: true),
              ],
              rows: [
                for (final item in invoice.invoiceItems)
                  DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [Text(item.item.name)],
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Text(item.size),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Text(item.quantity.toString()),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: DiscountedPrice(price: item.item.price, discount: item.item.discount),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Text('${item.totalPrice} د.ل'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أصناف الفاتورة:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final item in invoice.invoiceItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'الحجم: ${item.size}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الكمية:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.item.discountedPrice < item.item.price) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر قبل التخفيض:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${item.item.price.toStringAsFixed(2)} د.ل',
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
                        const Text(
                          'السعر بعد التخفيض:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${item.item.discountedPrice.toStringAsFixed(2)} د.ل',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${item.item.price.toStringAsFixed(2)} د.ل',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي السعر:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} د.ل',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              width: 200,
              child: Text(
                'الإجمالي:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '${readableMoney(invoice.total)} د.ل',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (invoice.savings > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(
                width: 200,
                child: Text(
                  'لقد قمت بتوفير:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  '${readableMoney(invoice.savings)} د.ل',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class DiscountedPrice extends StatelessWidget {
  final double price;
  final double? discount;

  final TextStyle? style;

  const DiscountedPrice({super.key, required this.price, this.discount, this.style});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (discount != null && discount! > 0)
          Text(
            '${readableMoney(price)} د.ل',
            style: _style.copyWith(
              decoration: style?.decoration ?? TextDecoration.lineThrough,
              color: style?.color ?? Colors.red,
            ),
          ),
        Text(
          '${readableMoney(price - (discount ?? 0))} د.ل',
          style: _style.copyWith(
            fontWeight: style?.fontWeight ?? FontWeight.bold,
            color: style?.color ?? Colors.green,
          ),
        ),
      ],
    );
  }

  TextStyle get _style => style ?? const TextStyle();
}
