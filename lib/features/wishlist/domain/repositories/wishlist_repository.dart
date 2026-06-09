import '../entities/wishlist_item.dart';

abstract class WishlistRepository {
  List<WishlistItem> getWishlistItems();

  void addToWishlist(WishlistItem item);

  void removeFromWishlist(String id);

  bool isInWishlist(String id);
}