import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';
import '../../cart/presentation/bloc/cart_state.dart';
import '../../order/domain/entities/order_item.dart';
import '../../order/presentation/pages/order_success_file.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Checkout",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.iconTheme.color,
        ),
      ),

      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final items = state.items;
          final isCartEmpty = items.isEmpty;

          return Column(
            children: [
              /// ORDER ITEMS
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isDark ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.image,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "₹${item.price}",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "Quantity: ${item.quantity}",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              "₹${(item.price * item.quantity).toStringAsFixed(0)}",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// BOTTOM CHECKOUT SECTION
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
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

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// TOTAL ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: theme.textTheme.titleMedium,
                        ),

                        Text(
                          "₹${state.totalPrice.toStringAsFixed(2)}",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// PLACE ORDER BUTTON
                    CustomButton(
                      text: isCartEmpty ? "Cart Empty" : "Place Order",
                      backgroundColor: isCartEmpty
                          ? Colors.grey
                          : theme.colorScheme.primary,
                      width: size.width * 0.7,
                      height: size.height * 0.06,
                      onPressed: () async {
                        final cartBloc = context.read<CartBloc>();
                        final items = cartBloc.state.items;

                        // 1. Create order data
                        final orderBox = Hive.box<OrderItem>('ordersBox');

                        final order = OrderItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          productNames: items.map((e) => e.name).toList(),
                          total: cartBloc.state.totalPrice,
                          date: DateTime.now().toString().substring(0, 16),
                        );

                        // 2. Save order
                        await orderBox.add(order);

                        // 3. Clear cart
                        for (var item in items) {
                          cartBloc.add(RemoveItem(item.id));
                        }

                        // 4. Navigate to success page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrderSuccessPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),
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