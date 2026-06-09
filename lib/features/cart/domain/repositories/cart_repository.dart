import '../entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> getCartItems();

  void addToCart(CartItem item);

  void removeFromCart(String id);

  void updateQuantity(String id, int quantity);

  double getTotalPrice();
}