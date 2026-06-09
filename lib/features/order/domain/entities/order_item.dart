import 'package:hive/hive.dart';

part 'order_item.g.dart';

@HiveType(typeId: 4)
class OrderItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<String> productNames;

  @HiveField(2)
  final double total;

  @HiveField(3)
  final String date;

  OrderItem({
    required this.id,
    required this.productNames,
    required this.total,
    required this.date,
  });
}