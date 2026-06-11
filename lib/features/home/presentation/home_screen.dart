import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/centre_toast.dart';
import '../../../shared/widgets/product_card.dart';

import '../../product/data/product_repository.dart';
import '../../product/presentation/add_product_test_screen.dart';
import '../../product/presentation/product_details_screen.dart';

import '../../wishlist/bloc/wishlist_bloc.dart';
import '../../wishlist/bloc/wishlist_event.dart';
import '../../wishlist/bloc/wishlist_state.dart';
import '../../wishlist/domain/entities/wishlist_item.dart';
import '../../wishlist/presentation/pages/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository repo = ProductRepository();

  List<Product> products = [];
  bool isLoading = true;

  String selectedCategory = "All";
  String searchQuery = "";

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredProducts = products.where((product) {
      final matchesCategory =
          selectedCategory == "All" || product.category == selectedCategory;

      final matchesSearch = product.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();

    return BlocListener<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state.lastAction == "added") {
          CenterToast.show(context, "Added to wishlist");
        } else if (state.lastAction == "removed") {
          CenterToast.show(context, "Removed from wishlist");
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme.colorScheme.surface,
          title: const Text(
            "VEEMADEFORYOU",
            style: TextStyle(
              letterSpacing: 3,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.add_box_outlined),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const AddProductTestScreen(),
            //       ),
            //     );
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    "Hello, Crochet Lover",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Find your favorite handmade creations",
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search crochet products...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/banner/banner.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Categories",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    selectedCategory == "All"
                        ? "All Products"
                        : selectedCategory,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  BlocBuilder<WishlistBloc, WishlistState>(
                    builder: (context, state) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];

                          final isFavorite = state.items.any(
                            (item) => item.id == product.id,
                          );

                          return ProductCard(
                            name: product.name,
                            price: "₹${product.price}",
                            image: product.image,
                            isFavorite: isFavorite,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            onFavoriteTap: () {
                              if (isFavorite) {
                                context.read<WishlistBloc>().add(
                                  RemoveWishlistItem(product.id),
                                );
                              } else {
                                context.read<WishlistBloc>().add(
                                  AddWishlistItem(
                                    WishlistItem(
                                      id: product.id,
                                      name: product.name,
                                      price: product.price,
                                      image: product.image,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
