import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

class Item extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final List<String> sizes;
  final List<String> images;
  final double price;
  final double? discount;

  const Item({
    this.id,
    required this.name,
    this.description,
    required this.sizes,
    required this.images,
    required this.price,
    this.discount,
  });

  Item.copyWith(
    Item item, {
    String? id,
    String? name,
    String? description,
    List<String>? sizes,
    List<String>? images,
    double? price,
    double? discount,
  })  : id = id ?? item.id,
        name = name ?? item.name,
        description = description ?? item.description,
        sizes = sizes ?? item.sizes,
        images = images ?? item.images,
        price = price ?? item.price,
        discount = discount ?? item.discount;

  Item copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? sizes,
    List<String>? images,
    double? price,
    double? discount,
  }) =>
      Item.copyWith(
        this,
        id: id,
        name: name,
        description: description,
        sizes: sizes,
        images: images,
        price: price,
        discount: discount,
      );

  Item.fromJson(JsonMap json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        sizes = List.from(json['sizes'] ?? []),
        images = List.from(json['images'] ?? []),
        price = json['price'],
        discount = json['discount'];

  JsonMap get toJson => {
        'id': id,
        'name': name,
        'description': description,
        'sizes': sizes,
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
        description,
        ...sizes,
        ...images,
        price,
        discount,
        effectivePrice,
      ];
}
