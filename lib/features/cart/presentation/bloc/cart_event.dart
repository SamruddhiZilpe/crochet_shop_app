import '../../domain/entities/cart_item.dart';

abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddItem extends CartEvent {
  final CartItem item;

  AddItem({required this.item});
}

class RemoveItem extends CartEvent {
  final String id;

  RemoveItem(this.id);
}

class UpdateQuantity extends CartEvent {
  final String id;
  final int quantity;

  UpdateQuantity(this.id, this.quantity);
}