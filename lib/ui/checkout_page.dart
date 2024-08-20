import 'dart:math';

import 'package:arabiya/models/bill.dart';
import 'package:arabiya/pdf/reporting.dart';
import 'package:arabiya/ui/cart_notifier.dart';
import 'package:arabiya/ui/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:url_launcher/url_launcher_string.dart';

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
                      recipientPhone: ref.read(phoneProvider),
                      recipientAddress: ref.read(addressProvider),
                      latitude: ref.read(locationProvider).latitude,
                      longitude: ref.read(locationProvider).longitude,
                      cartItems: ref.read(CartNotifier.groupedItemsProvider),
                      createAt: DateTime.now(),
                    );

                    return FutureBuilder(
                      // future: compute<Bill, Uint8List>(
                      //   Reporting.createPdfBill,
                      //   bill,
                      // ),
                      future: Reporting.createPdfBill(bill),
                      builder: (context, snapshot) {
                        // if (snapshot.hasError) {
                        //   return Text('${snapshot.error}');
                        // }

                        if (snapshot.hasData) {
                          return PdfViewer.data(snapshot.requireData, sourceName: "فاتورة");
                        }

                        return const SizedBox.square(
                          dimension: 32,
                          child: Center(child: CircularProgressIndicator(color: Colors.red)),
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
                    return ElevatedButton(
                      onPressed: () async {
                        if (pdfBytes != null) {
                          final filename =
                              '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}-'
                              '${Random().nextInt(256).toRadixString(16)}.pdf';

                          // await Share.shareXFiles(
                          //   [
                          //     XFile.fromData(
                          //       pdfBytes!,
                          //       mimeType: 'application/pdf',
                          //       name: 'invoce.pdf',
                          //     ),
                          //   ],
                          //
                          // );

                          final url = await savePdf(pdfBytes!, filename);
                          final text =
                              'مرحبا!! أريد طلب المنتجات الموجودة في هذه الفاتورة : $url';
                          // launchUrlString('https://wa.me/+218910215272/?text=$text');
                          launchUrlString(
                            'whatsapp://send?phone=+218910215272&text=$text',
                          );

                          ServicesBinding.instance.addPostFrameCallback(
                            (_) {
                              // TODO restore all providers
                              ref
                                  .read(CartNotifier.itemsProvider.notifier)
                                  .empty();
                              ref.read(nameProvider.notifier).state = '';
                              ref.read(phoneProvider.notifier).state = '';
                              ref.read(addressProvider.notifier).state = '';

                              Navigator.popUntil(
                                context,
                                ModalRoute.withName('/'),
                              );
                            },
                          );
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
                    );
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

  Future<String> savePdf(Uint8List data, String name) async {
    final reference = FirebaseStorage.instance.ref().child(name);
    final taskSnapshot = await reference.putData(data);
    final url = await taskSnapshot.ref.getDownloadURL();
    return url;
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
