import '../domain/entities/wishlist_item.dart';

class WishlistState {
  final List<WishlistItem> items;

  WishlistState({
    required this.items,
  });

  factory WishlistState.initial() {
    return WishlistState(items: []);
  }

  WishlistState copyWith({
    List<WishlistItem>? items,
  }) {
    return WishlistState(
      items: items ?? this.items,
    );
  }
}