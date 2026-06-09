import 'package:hive/hive.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final Box<WishlistItem> _box = Hive.box<WishlistItem>('wishlistBox');

  @override
  List<WishlistItem> getWishlistItems() {
    return _box.values.toList();
  }

  @override
  void addToWishlist(WishlistItem item) {
    final exists = _box.values.any((e) => e.id == item.id);

    if (!exists) {
      _box.add(item);
    }
  }

  @override
  void removeFromWishlist(String id) {
    final index = _box.values.toList().indexWhere((e) => e.id == id);

    if (index != -1) {
      _box.deleteAt(index);
    }
  }

  @override
  bool isInWishlist(String id) {
    return _box.values.any((e) => e.id == id);
  }
}