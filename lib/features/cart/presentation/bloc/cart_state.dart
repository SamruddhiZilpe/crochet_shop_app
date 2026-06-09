import '../../domain/entities/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final double totalPrice;

  CartState({
    required this.items,
    required this.totalPrice,
  });

  factory CartState.initial() {
    return CartState(
      items: [],
      totalPrice: 0,
    );
  }

  CartState copyWith({
    List<CartItem>? items,
    double? totalPrice,
  }) {
    return CartState(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}