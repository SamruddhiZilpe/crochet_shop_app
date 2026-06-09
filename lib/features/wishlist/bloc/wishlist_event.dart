import '../domain/entities/wishlist_item.dart';

abstract class WishlistEvent {}

class LoadWishlist extends WishlistEvent {}

class AddWishlistItem extends WishlistEvent {
  final WishlistItem item;

  AddWishlistItem(this.item);
}

class RemoveWishlistItem extends WishlistEvent {
  final String id;

  RemoveWishlistItem(this.id);
}