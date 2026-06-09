import 'package:hive/hive.dart';

part 'wishlist_item.g.dart';

@HiveType(typeId: 3)
class WishlistItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String image;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });
}