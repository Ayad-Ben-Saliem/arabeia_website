import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

class Item extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final List<String> images;
  final double price;
  final double? discount;

  Item({
    this.id,
    required this.name,
    this.description,
    required this.images,
    required this.price,
    this.discount,
  });

  Item.copyWith(
    Item item,
    String? id,
    String? name,
    String? description,
    List<String>? images,
    double? price,
    double? discount,
  )   : id = id ?? item.id,
        name = name ?? item.name,
        description = description ?? item.description,
        images = images ?? item.images,
        price = price ?? item.price,
        discount = discount ?? item.discount;

  Item copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    double? price,
    double? discount,
  }) =>
      Item.copyWith(
        this,
        id,
        name,
        description,
        images,
        price,
        discount,
      );

  Item.fromJson(JsonMap json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        images = List.from(json['images']),
        price = json['price'],
        discount = json['discount'];

  JsonMap get toJson => {
        'id': id,
        'name': name,
        'description': description,
        'images': images,
        'price': price,
        'discount': discount,
      };

  @override
  String toString() {
    return 'Item($name)';
  }

  double get effectivePrice => price - (discount ?? 0);

  @override
  List<Object?> get props => [
    id,
    name,
    // ...images,
    price,
    discount,
    effectivePrice,
  ];
}
