import 'package:hive/hive.dart';

import '../../domain/entities/cart_item.dart';

class CartHiveRepository {
  final Box<CartItem> box = Hive.box<CartItem>('cartBox');

  List<CartItem> getCartItems() {
    return box.values.toList();
  }

  void addToCart(CartItem item) {
    final index = box.values.toList().indexWhere(
          (e) => e.id == item.id,
    );

    if (index != -1) {
      final existing = box.getAt(index)!;

      final updated = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );

      box.putAt(index, updated);
    } else {
      box.add(item);
    }
  }

  void removeFromCart(String id) {
    final index = box.values.toList().indexWhere(
          (e) => e.id == id,
    );

    if (index != -1) {
      box.deleteAt(index);
    }
  }

  void clearCart() {
    box.clear();
  }
}