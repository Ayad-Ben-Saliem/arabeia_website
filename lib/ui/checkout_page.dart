import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/invoice.dart';
import 'package:arabiya/pdf/reporting.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/invoice_viewer.dart';
import 'package:arabiya/ui/user_address_page.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabiya/ui/widgets/item_card.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher_string.dart';

final socialMethod = StateProvider((ref) => 'W');
Uint8List? pdfBytes;

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = Invoice(
      recipientName: ref.read(nameProvider),
      recipientPhone: ref.read(phoneProvider),
      recipientAddress: ref.read(addressProvider),
      latitude: ref.read(locationProvider).latitude,
      longitude: ref.read(locationProvider).longitude,
      invoiceItems: ref.read(CartNotifier.groupedItemsProvider),
      createAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ارسال الفاتورة'),
        actions: [
          IconButton(
            onPressed: () async => Printing.sharePdf(bytes: await Reporting.createPdfInvoice(invoice)),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            children: [
              Expanded(
                child: InvoiceViewer(invoice: invoice),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final savedInvoice = await Database.addInvoice(invoice);
                    final invoiceUrl = '$baseUrl/#/invoices/${savedInvoice.id}';
                    final text = 'مرحبا!! أريد طلب المنتجات الموجودة في هذه الفاتورة:\n\n$invoiceUrl';
                    launchUrlString('whatsapp://send?phone=+218913238833&text=${Uri.encodeComponent(text)}');

                    _reset(ref);

                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    Navigator.pushNamed(context, '/invoices/${savedInvoice.id}');
                  },
                  // },

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('إرسال'),
                      SizedBox(width: 8),
                      Icon(Icons.send),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _reset(WidgetRef ref) {
    ref.read(CartNotifier.itemsProvider.notifier).empty();
    ref.read(nameProvider.notifier).state = '';
    ref.read(phoneProvider.notifier).state = '';
    ref.read(addressProvider.notifier).state = '';
    ref.read(resetSizeProvider.notifier).state = ref.read(resetSizeProvider) + 1;
  }
}

class SocialMethod extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Color color;
  final GestureTapCallback? onTap;

  const SocialMethod({
    super.key,
    required this.icon,
    required this.title,
    this.active = false,
    this.color = Colors.grey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: active ? color : null,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(icon),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }
}
