import 'package:arabeia_website/models/bill.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';

abstract class Reporting {
  static Future<Uint8List> createPdfBill(Bill bill) async {
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
        // textDirection: TextDirection.rtl,
        build: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Container(
                  width: constraints?.maxWidth ?? 480,
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header(bill, logo),
                      SizedBox(height: 32),
                      table(bill),
                      SizedBox(height: 32),
                      footer(bill),
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

  static Widget header(Bill bill, ImageProvider logo) {
    return CustomRow(
      textDirection: TextDirection.rtl,
      children: [
        CustomColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('اســم المستلم'),
            CustomText('رقــم الهـاتـف'),
            CustomText('عنوان المستلم'),
            CustomText('التـــــــــاريــــخ'),
          ],
        ),
        CustomColumn(
          children: [
            CustomText(' :'),
            CustomText(' :'),
            CustomText(' :'),
            CustomText(' :'),
          ],
        ),
        CustomColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(bill.recipientName),
            CustomText(bill.recipientPhone),
            CustomText(bill.recipientAddress),
            CustomText(format(bill.createAt)),
          ],
        ),
        Spacer(),
        SizedBox(
          height: 64,
          width: 64,
          child: Image(logo),
        ),
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
        '${hour % 12}:$minute ${hour < 12 ? 'AM' : 'PM'}';
  }

  static Widget table(Bill bill) {
    final cartItems = bill.cartItems;

    return Table(
      columnWidths: {
        0: const FixedColumnWidth(60),
        1: const FixedColumnWidth(80),
        2: const FixedColumnWidth(40),
        3: const FixedColumnWidth(40),
        4: const FractionColumnWidth(0.5),
      },
      children: [
        TableRow(
          children: [
            CustomText('المجموع (د.ل)'),
            CustomText('سعر الوحدة (د.ل)'),
            CustomText('الكمية'),
            CustomText('الحجم'),
            CustomText('اسم الصنف'),
          ],
        ),
        TableRow(
          children: [for (int i = 0; i < 5; i++) Divider()],
        ),
        for (int i = 0; i < cartItems.length; i++) ...[
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: CustomText('${cartItems.elementAt(i).totalPrice}'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: priceWidget(cartItems.elementAt(i).item),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: CustomText('${cartItems.elementAt(i).quantity}'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: CustomText(cartItems.elementAt(i).size),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: CustomText(cartItems.elementAt(i).item.name),
              ),
            ],
          ),
          TableRow(
            children: [for (int i = 0; i < 5; i++) Divider(thickness: 0.25)],
          ),
        ],
      ],
    );
  }

  static Widget priceWidget(Item item) {
    // if (item.discount != null) {
    //   return CustomColumn(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       CustomText(
    //         '${item.price}',
    //         style: const TextStyle(
    //           decoration: TextDecoration.lineThrough,
    //         ),
    //       ),
    //       CustomText('${item.effectivePrice}'),
    //     ],
    //   );
    // }
    return CustomText('${item.effectivePrice}');
  }

  static Widget footer(Bill bill) {
    const googleMapUrl = 'https://www.google.com/maps/';
    return CustomRow(
      children: [
        CustomColumn(children: [
          BarcodeWidget(
            data: '$googleMapUrl@${bill.latitude},${bill.longitude},15z',
            barcode: Barcode.qrCode(),
            width: 64,
            height: 64,
          ),
          Text('الموقع'),
        ]),
        Spacer(),
        Text(
          'المجموع: ${bill.total} د.ل',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
