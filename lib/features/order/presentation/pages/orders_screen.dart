import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/order_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<OrderItem>('ordersBox');
    final orders = box.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: orders.isEmpty
          ? const Center(child: Text("No orders yet"))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text("Order ${order.id.substring(0, 6)}"),
              subtitle: Text(
                "${order.productNames.join(", ")}\n${order.date}",
              ),
              trailing: Text("₹${order.total}"),
            ),
          );
        },
      ),
    );
  }
}