class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      image: data['image'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'image': image, 'category': category};
  }
}
