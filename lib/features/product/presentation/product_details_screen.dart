import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/centre_toast.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/domain/entities/cart_item.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(product.name, style: theme.textTheme.titleMedium),
        iconTheme: theme.iconTheme,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  product.image,
                  height: 600,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PRODUCT NAME
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PRICE
                  Text(
                    "₹${product.price}",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  Text(
                    "This is a handmade crochet product made with love 💗 Perfect for gifting, decoration, and special occasions.",
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 30),

                  /// ADD TO CART BUTTON
                  CustomButton(
                    width: size.width * 0.9,
                    height: size.height * 0.06,
                    text: "Add to Cart",
                    backgroundColor: theme.colorScheme.primary,
                    onPressed: () async {
                      context.read<CartBloc>().add(
                        AddItem(
                          item: CartItem(
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            image: product.image,
                            quantity: 1,
                          ),
                        ),
                      );
                      CenterToast.show(context, "Added to Cart");
                    },
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
