import 'package:arabiya/models/invoice.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/utils.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';

abstract class Reporting {
  static Future<Uint8List> createPdfInvoice(Invoice invoice) async {
    // final font = await PdfGoogleFonts.robotoRegular();
    final font = await fontFromAssetBundle(
      'assets/fonts/HacenTunisia/Regular.ttf',
    );
    final fontBold = await fontFromAssetBundle(
      'assets/fonts/HacenTunisia/Bold-Regular.ttf',
    );

    final logo = await imageFromAssetBundle('assets/images/logo.webp');

    final pdf = Document();

    pdf.addPage(
      Page(
        pageTheme: PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: ThemeData(
            defaultTextStyle: TextStyle(font: font, fontBold: fontBold),
          ),
          textDirection: TextDirection.rtl,
        ),
        build: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Container(
                  width: constraints?.maxWidth ?? 480,
                  child: Column(
                    children: [
                      header(invoice, logo),
                      SizedBox(height: 32),
                      table(invoice),
                      SizedBox(height: 32),
                      footer(invoice),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text('المستلم: . . . . . . . . . . . . . . . .'),
                      ),
                      SizedBox(height: 32),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Created by Manassa Ltd - manassa.ly',
                          style: const TextStyle(
                            color: PdfColors.grey,
                            fontSize: 10
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    return pdf.save();
  }

  static Widget header(Invoice invoice, ImageProvider logo) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('اســم المستلم'),
            Text('رقــم الهـاتـف'),
            Text('عنوان المستلم'),
            Text('التـــــــــاريــــخ'),
          ],
        ),
        Column(
          children: [
            Text('  :'),
            Text('  :'),
            Text('  :'),
            Text('  :'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.recipientName),
            Text(invoice.recipientPhone),
            Text(invoice.recipientAddress),
            Text(format(invoice.createAt)),
          ],
        ),
        Spacer(),
        SizedBox.square(dimension: 64, child: Image(logo)),
      ],
    );
  }

  static String format(DateTime dateTime) {
    final year = '${dateTime.year}';
    final month = '${dateTime.month}';
    final day = '${dateTime.day}';
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    return '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')} '
        '${hour % 12}:$minute ${hour < 12 ? 'ص' : 'م'}';
  }

  static Widget table(Invoice invoice) {
    final invoiceItems = invoice.invoiceItems;

    return Table(
      columnWidths: {
        0: const FixedColumnWidth(50),
        1: const FixedColumnWidth(60),
        2: const FixedColumnWidth(40),
        3: const FixedColumnWidth(40),
        4: const FractionColumnWidth(0.5),
      },
      children: [
        TableRow(
          children: [
            Text('المجموع', textAlign: TextAlign.center),
            Text('سعر الوحدة', textAlign: TextAlign.center),
            Text('الكمية', textAlign: TextAlign.center),
            Text('الحجم', textAlign: TextAlign.center),
            Text('اسم الصنف', textAlign: TextAlign.center),
          ],
        ),
        TableRow(children: [for (int i = 0; i < 5; i++) Divider(height: 1, thickness: 1)]),
        for (int i = 0; i < invoiceItems.length; i++) ...[
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text('${invoiceItems.elementAt(i).totalPrice}', textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: priceWidget(invoiceItems.elementAt(i).item),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text('${invoiceItems.elementAt(i).quantity}', textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  // Use column to fill all available vertical space
                  children: [Text(invoiceItems.elementAt(i).size, textAlign: TextAlign.center)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(invoiceItems.elementAt(i).item.name),
              ),
            ],
          ),
          TableRow(children: [for (int i = 0; i < 5; i++) Divider(height: 0.25, thickness: 0.25)]),
        ],
      ],
    );
  }

  static Widget priceWidget(Item item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (item.discount != null)
          Text(
            '${item.price}',
            style: const TextStyle(decoration: TextDecoration.lineThrough, color: PdfColors.grey),
          ),
        Text('${item.discountedPrice}'),
      ],
    );
  }

  static Widget footer(Invoice invoice) {
    const googleMapUrl = 'https://www.google.com/maps/';
    return Row(
      children: [
        Column(
          children: [
            BarcodeWidget(
              data: '$googleMapUrl@${invoice.latitude},${invoice.longitude},15z',
              barcode: Barcode.qrCode(),
              width: 64,
              height: 64,
            ),
            Text('الموقع'),
          ],
        ),
        SizedBox(width: 64),
        Column(
          children: [
            BarcodeWidget(
              data: '$baseUrl/invoices/${invoice.id}',
              barcode: Barcode.qrCode(),
              width: 64,
              height: 64,
            ),
            Text('الفاتورة'),
          ],
        ),
        Spacer(),
        Column(children: [
          Text(
            'الإجمالي: ${invoice.total} د.ل',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'لقد ادخرت: ${invoice.savings} د.ل',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ]),
      ],
    );
  }
}
