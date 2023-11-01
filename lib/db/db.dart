import 'package:arabiya/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static final _db = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _itemsRef =
      _db.collection('Items');

  static Future<Iterable<Item>> getItems() async {
    final query = await _itemsRef.get();

    return query.docs.map(
      (doc) => Item.fromJson({'id': doc.id, ...doc.data()}),
    );
  }

  static Future<Item?> getItem(String id) async {
    final doc = await _itemsRef.doc(id).get();
    if (doc.exists) return Item.fromJson(doc.data()!);
    return null;
  }

  static Future<Item> addItem(Item item) async {
    final docRef = await _itemsRef.add(item.toJson..remove('id'));
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
    await _itemsRef.doc(item.id).update(item.toJson..remove('id'));
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
}
