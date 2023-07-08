import 'package:arabeia_website/models/item.dart';
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
    final query = await _itemsRef.where('id', isEqualTo: id).get();

    return query.docs
        .map((doc) => Item.fromJson({'id': doc.id, ...doc.data()}))
        .single;
  }
}
