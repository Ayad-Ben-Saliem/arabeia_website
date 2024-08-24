import 'package:arabiya/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/invoice.dart';

class Database {
  static final _db = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _itemsRef =
      _db.collection('Items');

  static final CollectionReference<Map<String, dynamic>> _invoicesRef = _db.collection('invoices');


  static Future<Iterable<Item>> getItems() async {
    final query = await _itemsRef.get();

    return query.docs.map(
      (doc) => Item.fromJson({...doc.data(), 'id': doc.id}),
    );
  }

  static Future<Item?> getItem(String id) async {
    final doc = await _itemsRef.doc(id).get();
    if (doc.exists) return Item.fromJson(doc.data()!);
    return null;
  }

  static Future<Invoice> addInvoice(Invoice invoice) async {
    final docRef = await _invoicesRef.add(invoice.toJson());
    final doc = await docRef.get();
    final data = doc.data()!;
    data['id'] = docRef.id;
    return Invoice.fromJson(data);
  }

  static Future<Invoice?> getInvoice(String id) async {
    final doc = await _invoicesRef.doc(id).get();
    final data = doc.data()!;
    data['id'] = doc.id;
    if (doc.exists) return Invoice.fromJson(data);
    return null;
  }

  static Future<List<Invoice>> getInvoices() async {
    final query = await _invoicesRef.get();
    final invoices = query.docs.map((doc) {
      final data = {...doc.data(), 'id': doc.id};
      return Invoice.fromJson(data);
    }).toList();
    return invoices;
  }

  static void deleteInvoice(invoice) {
    _invoicesRef.doc(invoice.id).delete();
  }
}
