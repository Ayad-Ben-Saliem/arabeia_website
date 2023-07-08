import 'package:arabeia_website/models/bill.dart';
import 'package:arabeia_website/pdf/reporting.dart';
import 'package:arabeia_website/ui/app.dart';
import 'package:arabeia_website/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:share_plus/share_plus.dart';

final socialMethod = StateProvider((ref) => 'W');
Uint8List? pdfBytes;

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ارسال الفاتورة'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            children: [
              Expanded(
                child: Consumer(
                  builder: (context, ref, widget) {
                    final bill = Bill(
                      recipientName: ref.read(nameProvider),
                      recipientPhone: ref.read(nameProvider),
                      recipientAddress: ref.read(nameProvider),
                      latitude: 0,
                      // TODO
                      longitude: 0,
                      // TODO
                      cartItems: ref.read(CartItems.sortedItemsProvider),
                      createAt: DateTime.now(),
                    );
                    return FutureBuilder(
                      future: Reporting.createPdfBill(bill),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return Text('${snapshot.error}');
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            height: 32,
                            width: 32,
                            child: Center(
                                child: CircularProgressIndicator(
                              color: Colors.red,
                            )),
                          );
                        }

                        pdfBytes = snapshot.data;
                        return SfPdfViewer.memory(
                          snapshot.data!,
                          initialZoomLevel: -1,
                        );
                      },
                    );
                  },
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Consumer(
                  builder: (context, ref, widget) {
                    final isWhatsApp = ref.watch(socialMethod) == 'W';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SocialMethod(
                          icon: Icons.whatshot,
                          title: 'واتساب',
                          active: isWhatsApp,
                          onTap: () =>
                              ref.read(socialMethod.notifier).state = 'W',
                        ),
                        SocialMethod(
                          icon: Icons.telegram,
                          title: 'تيليجرام',
                          active: !isWhatsApp,
                          onTap: () =>
                              ref.read(socialMethod.notifier).state = 'T',
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (pdfBytes != null) {
                      print('sharing pdf ...');
                      // launchUrlString('https://wa.me/+218910215272/?text=test');
                      // Printing.sharePdf(bytes: pdfBytes!);
                      final result = await Share.shareXFiles([
                        XFile.fromData(
                          pdfBytes!,
                          mimeType: 'application/pdf',
                          name: 'invoce.pdf',
                        ),
                      ]);
                      print(result);
                    }
                  },
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
