import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(CartState.initial()) {
    on<LoadCart>(_onLoadCart);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateQuantity>(_onUpdateQuantity);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    final items = repository.getCartItems();

    emit(state.copyWith(
      items: items,
      totalPrice: repository.getTotalPrice(),
    ));
  }

  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    repository.addToCart(event.item);

    final updatedItems = repository.getCartItems();

    emit(state.copyWith(
      items: updatedItems,
      totalPrice: repository.getTotalPrice(),
    ));
  }

  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    repository.removeFromCart(event.id);

    final updatedItems = repository.getCartItems();

    emit(state.copyWith(
      items: updatedItems,
      totalPrice: repository.getTotalPrice(),
    ));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    repository.updateQuantity(event.id, event.quantity);

    final updatedItems = repository.getCartItems();

    emit(state.copyWith(
      items: updatedItems,
      totalPrice: repository.getTotalPrice(),
    ));
  }
}