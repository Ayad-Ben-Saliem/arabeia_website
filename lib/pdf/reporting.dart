import 'package:arabeia_website/models/bill.dart';
import 'package:arabeia_website/models/item.dart';
import 'package:arabeia_website/pdf/pdf.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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

    final logo = await imageFromAssetBundle('assets/images/logo.webp');

    final pdf = Document();

    pdf.addPage(
      Page(
        pageTheme: PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: ThemeData(defaultTextStyle: TextStyle(font: font)),
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
            CustomText(
              DateFormat('yyyy-MM-dd E hh:mm a').format(bill.createAt),
            ),
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

  static Widget table(Bill bill) {
    final cartItems = bill.cartItems;

    return Table(
      columnWidths: {
        0: const FractionColumnWidth(0.2),
        1: const FractionColumnWidth(0.2),
        2: const FractionColumnWidth(0.1),
        3: const FractionColumnWidth(0.5),
      },
      children: [
        TableRow(
          children: [
            CustomText('الإجمالي (د.ل)'),
            CustomText('سعر الوحدة (د.ل)'),
            CustomText('الكمية'),
            CustomText('اسم الصنف'),
          ],
        ),
        TableRow(
          children: [for (int i = 0; i < 4; i++) Divider()],
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
                child: CustomText(cartItems.elementAt(i).item.name),
              ),
            ],
          ),
          TableRow(
            children: [for (int i = 0; i < 4; i++) Divider(thickness: 0.25)],
          ),
        ],
      ],
    );
  }

  static Widget priceWidget(Item item) {
    if (item.discount != null) {
      return CustomColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            '${item.price}',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          ),
          CustomText('${item.effectivePrice}'),
        ],
      );
    }
    return CustomText('${item.effectivePrice}');
  }
}
