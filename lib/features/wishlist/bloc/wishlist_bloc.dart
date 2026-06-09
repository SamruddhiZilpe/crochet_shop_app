import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository repository;

  WishlistBloc(this.repository) : super(WishlistState.initial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<AddWishlistItem>(_onAddWishlistItem);
    on<RemoveWishlistItem>(_onRemoveWishlistItem);
  }

  void _onLoadWishlist(
      LoadWishlist event,
      Emitter<WishlistState> emit,
      ) {
    emit(
      state.copyWith(
        items: repository.getWishlistItems(),
      ),
    );
  }

  void _onAddWishlistItem(
      AddWishlistItem event,
      Emitter<WishlistState> emit,
      ) {
    repository.addToWishlist(event.item);

    emit(
      state.copyWith(
        items: repository.getWishlistItems(),
      ),
    );
  }

  void _onRemoveWishlistItem(
      RemoveWishlistItem event,
      Emitter<WishlistState> emit,
      ) {
    repository.removeFromWishlist(event.id);

    emit(
      state.copyWith(
        items: repository.getWishlistItems(),
      ),
    );
  }
}