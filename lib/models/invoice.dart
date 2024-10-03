import 'package:arabiya/models/invoice_item.dart';
import 'package:arabiya/utils.dart';

class Invoice {
  final String? id;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final double latitude;
  final double longitude;
  final Iterable<InvoiceItem> invoiceItems;
  final String? note;
  final DateTime createAt;

  const Invoice({
    this.id,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.latitude,
    required this.longitude,
    required this.invoiceItems,
    this.note,
    required this.createAt,
  });

  double get original {
    var original = 0.0;
    for (final cartItem in invoiceItems) {
      original += cartItem.originalPrice;
    }
    return original;
  }

  double get total {
    var total = 0.0;
    for (final cartItem in invoiceItems) {
      total += cartItem.totalPrice;
    }
    return total;
  }

  double get savings => original - total;

  JsonMap toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'recipientAddress': recipientAddress,
      'latitude': latitude,
      'longitude': longitude,
      'invoiceItems': invoiceItems.map((item) => item.toJson()).toList(),
      'note' : note,
      'createAt': createAt.toUtc().toString(),
    };
  }

  static Invoice fromJson(Map<String, dynamic> data) {
    final invoiceItems = List<InvoiceItem>.from(
      data['invoiceItems'].map((item) => InvoiceItem.fromJson(item)),
    );

    return Invoice(
      id: data['id'],
      recipientName: data['recipientName'],
      recipientPhone: data['recipientPhone'],
      recipientAddress: data['recipientAddress'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      invoiceItems: invoiceItems,
      note: data['note'],
      createAt: DateTime.parse(data['createAt']),
    );
  }
}
