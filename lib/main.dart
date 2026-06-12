import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/themes/theme.dart';
import 'core/themes/theme_controller.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/entities/cart_item.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/order/domain/entities/order_item.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/wishlist/bloc/wishlist_bloc.dart';
import 'features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/wishlist/domain/entities/wishlist_item.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(WishlistItemAdapter());
  Hive.registerAdapter(OrderItemAdapter());

  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<OrderItem>('ordersBox');
  await Hive.openBox<WishlistItem>('wishlistBox');
  await Hive.openBox('userProfileBox');

  final themeController = ThemeController();
  await themeController.loadTheme();

  runApp(
    ChangeNotifierProvider.value(value: themeController, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CartBloc(CartRepositoryImpl())..add(LoadCart()),
        ),
        BlocProvider(create: (_) => WishlistBloc(WishlistRepositoryImpl())),
      ],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const SplashScreen(),
    );
  }
}
