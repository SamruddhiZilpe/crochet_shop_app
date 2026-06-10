import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/product_card.dart';

import '../../cart/presentation/pages/cart_page.dart';
import '../../product/presentation/product_details_screen.dart';

import '../../wishlist/bloc/wishlist_bloc.dart';
import '../../wishlist/bloc/wishlist_event.dart';
import '../../wishlist/bloc/wishlist_state.dart';
import '../../wishlist/domain/entities/wishlist_item.dart';
import '../../wishlist/presentation/pages/wishlist_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Product> products = [
    Product(
      id: "1",
      name: "Crochet Bunny",
      price: 699,
      image: "assets/images/product/bunny_crochet.jpeg",
      category: "Plushies",
    ),
    Product(
      id: "2",
      name: "Tulip Bouquet",
      price: 499,
      image: "assets/images/product/tulip_crochet.jpeg",
      category: "Flowers",
    ),
    Product(
      id: "3",
      name: "Tulip Pot",
      price: 199,
      image: "assets/images/product/tulip_pot_crochet.jpeg",
      category: "Flowers",
    ),
    Product(
      id: "4",
      name: "Avo Keychain",
      price: 199,
      image: "assets/images/product/avo_crochet.jpeg",
      category: "Keychains",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WishlistScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// WELCOME
          Text(
            "Hello, Crochet Lover ",
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

          /// SEARCH BAR
          TextField(
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

          /// BANNER
          Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: AssetImage(
                  "assets/images/banner/banner.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Made with love, stitched for you",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// CATEGORIES
          Text(
            "Categories",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryChip("All"),
                _categoryChip("Flowers"),
                _categoryChip("Plushies"),
                _categoryChip("Keychains"),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// PRODUCTS
          Text(
            "All Products",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return BlocBuilder<
                  WishlistBloc,
                  WishlistState>(
                builder: (context, state) {
                  final isFavorite =
                  state.items.any(
                        (item) =>
                    item.id == product.id,
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
                              ProductDetailsScreen(
                                product: product,
                              ),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      if (isFavorite) {
                        context
                            .read<WishlistBloc>()
                            .add(
                          RemoveWishlistItem(
                            product.id,
                          ),
                        );
                      } else {
                        context
                            .read<WishlistBloc>()
                            .add(
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
    );
  }

  Widget _categoryChip(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(title),
      ),
    );
  }
}