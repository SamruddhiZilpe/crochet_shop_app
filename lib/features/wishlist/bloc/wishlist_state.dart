import '../domain/entities/wishlist_item.dart';

class WishlistState {
  final List<WishlistItem> items;
  final String? lastAction;

  WishlistState({
    required this.items,
    this.lastAction,
  });

  factory WishlistState.initial() {
    return WishlistState(items: [], lastAction: null);
  }

  WishlistState copyWith({
    List<WishlistItem>? items,
    String? lastAction,
  }) {
    return WishlistState(
      items: items ?? this.items,
      lastAction: lastAction,
    );
  }
}