import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/invoice.dart';
import 'package:arabiya/pdf/reporting.dart';
import 'package:arabiya/ui/invoice_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

final invoiceProvider = StateProvider<Invoice?>((ref) => null);

class InvoicePage extends StatelessWidget {
  final String invoiceId;

  const InvoicePage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('فاتورة مبيعات - $invoiceId'),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final invoice = ref.watch(invoiceProvider);
                if (invoice == null) return Container();
                return IconButton(
                  onPressed: () async => Printing.sharePdf(bytes: await Reporting.createPdfInvoice(invoice)),
                  icon: const Icon(Icons.download),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<Invoice?>(
          future: Database.getInvoice(invoiceId), // Get the invoice asynchronously
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for the data
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    const Text('حدث خطأ يرجى التواصل مع مطور المتجر'),
                    Text('Error: ${snapshot.error}'),
                    SingleChildScrollView(child: Text('Error: ${snapshot.stackTrace}')),
                  ],
                );
              } else if (snapshot.hasData) {
                return Consumer(
                  builder: (context, ref, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(invoiceProvider.notifier).state = snapshot.requireData!;
                    });
                    return InvoiceViewer(invoice: snapshot.requireData!);
                  },
                );
              } else {
                return const Center(child: Text('لم يتم العثور على الفاتورة'));
              }
            } else {
              return const Center(child: Text(' . . . '));
            }
          },
        ),
      ),
    );
  }
}
