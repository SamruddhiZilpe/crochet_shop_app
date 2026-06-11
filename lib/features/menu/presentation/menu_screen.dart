import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/centre_toast.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/domain/entities/cart_item.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';
import '../../product/data/product_repository.dart';
import '../../product/presentation/product_details_screen.dart';

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final ProductRepository repo = ProductRepository();

  List<Product> products = [];
  bool isLoading = true;

  String selectedCategory = "Keychains";

  final List<String> categories = [
    "All",
    "Flower Bouquet",
    "Decor",
    "Keychains",
    "Hair Accessories",
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await repo.getProducts();

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  List<Product> get filteredProducts {
    if (selectedCategory == "All") {
      return products;
    }

    return products.where((p) => p.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        /// LEFT SIDE (CATEGORIES)
        Container(
          width: size.width * 0.3,
          color: theme.cardColor,
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              final isSelected = selectedCategory == item;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = item;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.15)
                      : Colors.transparent,
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        /// RIGHT SIDE (PRODUCTS)
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            "No products found",
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.60,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black54
                                          : Colors.black12,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      product.image.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                product.image,
                                                height: 55,
                                                width: 55,
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }

                                                      return const SizedBox(
                                                        height: 70,
                                                        child: Center(
                                                          child: SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                errorBuilder: (_, _, _) =>
                                                    const Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                              ),
                                            )
                                          : const Icon(Icons.image, size: 40),

                                      Text(
                                        product.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),

                                      Text(
                                        "₹${product.price}",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),

                                      CustomButton(
                                        text: "Add",
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        height: 35,
                                        width: double.infinity,
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
                                          CenterToast.show(
                                            context,
                                            "Added to Cart",
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
