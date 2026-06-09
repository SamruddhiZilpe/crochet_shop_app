import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../checkout/presentation/checkout_page.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final isCartEmpty = state.items.isEmpty;

          if (isCartEmpty) {
            return Center(
              child: Text(
                "Cart is empty",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];

                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Image.asset(item.image, height: 60, width: 60),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "₹${item.price}",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    final newQty = item.quantity - 1;

                                    if (newQty <= 0) {
                                      context
                                          .read<CartBloc>()
                                          .add(RemoveItem(item.id));
                                    } else {
                                      context.read<CartBloc>().add(
                                        UpdateQuantity(
                                            item.id, newQty),
                                      );
                                    }
                                  },
                                ),
                                Text("${item.quantity}",
                                    style: theme.textTheme.bodyMedium),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    context.read<CartBloc>().add(
                                      UpdateQuantity(
                                          item.id, item.quantity + 1),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black54
                          : Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Total",
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          "₹${state.totalPrice.toStringAsFixed(2)}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    CustomButton(
                      text: isCartEmpty ? "Cart Empty" : "Checkout",
                      backgroundColor:
                      isCartEmpty ? Colors.grey : theme.primaryColor,
                      width: size.width * 0.65,
                      height: size.height * 0.06,
                      onPressed: isCartEmpty
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<CartBloc>(),
                              child: const CheckoutPage(),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}