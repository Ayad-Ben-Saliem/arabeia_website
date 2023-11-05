import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

class Item extends Equatable {
  final String? id;
  final String name;
  final int? order;
  final String? description;
  final List<String> sizes;
  final List<ArabiyaImages> images;
  final Map<String, String> images2;
  final double price;
  final double? discount;

  const Item({
    this.id,
    required this.name,
    this.order,
    this.description,
    required this.sizes,
    required this.images,
    required this.images2,
    required this.price,
    this.discount,
  });

  Item.copyWith(
    Item item, {
    String? id,
    String? name,
    int? order,
    String? description,
    List<String>? sizes,
    List<ArabiyaImages>? images,
    Map<String, String>? images2,
    double? price,
    double? discount,
  })  : id = id ?? item.id,
        name = name ?? item.name,
        order = order ?? item.order,
        description = description ?? item.description,
        sizes = sizes ?? item.sizes,
        images = images ?? item.images,
        images2 = images2 ?? item.images2,
        price = price ?? item.price,
        discount = discount ?? item.discount;

  Item copyWith({
    String? id,
    String? name,
    int? order,
    String? description,
    List<String>? sizes,
    List<ArabiyaImages>? images,
    Map<String, String>? images2,
    double? price,
    double? discount,
  }) =>
      Item.copyWith(
        this,
        id: id,
        name: name,
        order: order,
        description: description,
        sizes: sizes,
        images: images,
        images2: images2,
        price: price,
        discount: discount,
      );

  Item.fromJson(JsonMap json)
      : id = json['id'],
        name = json['name'],
        order = json['order'],
        description = json['description'],
        sizes = List.from(json['sizes'] ?? []),
        images = ArabiyaImages.fromJson(json['images']),
        images2 = Map.from(json['images2'] ?? {}),
        price = json['price'] ?? 0.0,
        discount = json['discount'] == null ? null : json['discount'] ?? 0.0;

  JsonMap get toJson => {
        'id': id,
        'name': name,
        'order': order,
        'description': description,
        'sizes': sizes,
        'images': images
            .map((image) => {
                  'fullHDImage': image.fullHDImage,
                  'thumbImage': image.thumbImage,
                })
            .toList(),
        'images2': images2,
        'price': price,
        'discount': discount,
      };

  @override
  String toString() => 'Item($name)';

  double get effectivePrice => price - (discount ?? 0);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ...sizes,
        ...images,
        ...images2.keys,
        ...images2.values,
        price,
        discount,
        effectivePrice,
      ];
}

class ArabiyaImages {
  final String fullHDImage;
  final String thumbImage;

  ArabiyaImages(this.fullHDImage, this.thumbImage);

  static List<ArabiyaImages> fromJson(dynamic m) {
    var l = <ArabiyaImages>[];
    for(var i in m) {
      l.add(ArabiyaImages(i, ""));
    }
    return l;
  }
}
