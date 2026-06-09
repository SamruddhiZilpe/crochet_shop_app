import 'package:hive/hive.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Box<CartItem> _box = Hive.box<CartItem>('cartBox');

  @override
  List<CartItem> getCartItems() {
    return _box.values.toList();
  }

  @override
  void addToCart(CartItem item) {
    final index = _box.values.toList().indexWhere(
          (e) => e.id == item.id,
    );

    if (index != -1) {
      final existing = _box.getAt(index)!;

      _box.putAt(
        index,
        existing.copyWith(
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _box.add(item);
    }
  }

  @override
  void removeFromCart(String id) {
    final index = _box.values.toList().indexWhere(
          (e) => e.id == id,
    );

    if (index != -1) {
      _box.deleteAt(index);
    }
  }

  @override
  void updateQuantity(String id, int quantity) {
    final index = _box.values.toList().indexWhere(
          (e) => e.id == id,
    );

    if (index != -1) {
      final item = _box.getAt(index)!;

      _box.putAt(
        index,
        item.copyWith(quantity: quantity),
      );
    }
  }

  @override
  double getTotalPrice() {
    return _box.values.fold(
      0.0,
          (sum, item) => sum + (item.price * item.quantity),
    );
  }
}