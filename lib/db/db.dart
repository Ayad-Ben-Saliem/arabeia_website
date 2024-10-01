import 'package:arabiya/models/invoice.dart';
import 'package:arabiya/models/item.dart';
import 'package:arabiya/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static final _db = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _itemsRef = _db.collection('Items');

  static final CollectionReference<Map<String, dynamic>> _invoicesRef = _db.collection('invoices');

  static final CollectionReference<Map<String, dynamic>> _managementRef = _db.collection('management');

  static Future<Iterable<Item>> getItems() async {
    final query = await _itemsRef.get();

    return query.docs.map((doc) => Item.fromJson({...doc.data(), 'id': doc.id}));
  }

  static Future<Iterable<Item>> getHomePageItems() async {
    final homePageData = await getHomePageData();
    final ids = homePageData['items'];
    final query = await _itemsRef.where(FieldPath.documentId, whereIn: ids).get();

    final docs = query.docs;
    docs.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return docs.map((doc) => Item.fromJson({...doc.data(), 'id': doc.id}));
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

  static Future<List<Invoice>> invoicesSearch({
    String? searchText,
    String? lastInvoiceId,
    int limit = 0,
  }) async {
    Query query = _invoicesRef.orderBy('createAt').limit(limit);
    if (lastInvoiceId != null) {
      final lastDocument = await _invoicesRef.doc(lastInvoiceId).get();
      query = query.startAfterDocument(lastDocument);
    }
    final querySnapshot = await query.get();
    final invoices = querySnapshot.docs.map((doc) {
      final Map<String, dynamic> data = {...doc.data()! as Map<String, dynamic>, 'id': doc.id};
      return Invoice.fromJson(data);
    }).toList();

    return invoices;
  }

  static void deleteInvoice(invoice) {
    _invoicesRef.doc(invoice.id).delete();
  }

  static Future<Item> addItem(Item item) async {
    final json = item.toJson()..remove('id');
    final docRef = await _itemsRef.add(json);
    final doc = await docRef.get();
    return Item.fromJson(doc.data()!);
  }

  static Stream<Item> addItems(Iterable<Item> items) async* {
    for (var item in items) {
      yield await addItem(item);
    }
  }

  static Future<Item> addUpdateItem(Item item) async {
    if (item.id == null) {
      return addItem(item);
    } else {
      await updateItem(item);
      return item;
    }
  }

  static Future<void> updateItem(Item item) async {
    final json = item.toJson()..remove('id');
    await _itemsRef.doc(item.id).update(json);
  }

  static Stream<void> updateItems(Iterable<Item> items) async* {
    for (var item in items) {
      updateItem(item);
    }
  }

  static Future<void> deleteItem(Item item) async {
    await _itemsRef.doc(item.id).delete();
  }

  static Stream<void> deleteItems(Iterable<Item> items) async* {
    for (var item in items) {
      deleteItem(item);
    }
  }

  static Future<JsonMap> getHomePageData() async {
    final doc = await _managementRef.doc('home-page').get();
    return doc.data()!;
  }

  static Future<void> updateHomePageData(JsonMap homePageData) async {
    await _managementRef.doc('home-page').update(homePageData);
  }
}
