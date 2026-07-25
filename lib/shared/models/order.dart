import 'package:flutter/material.dart';

/// A single line in an order (one dish with quantity).
@immutable
class OrderLine {
  const OrderLine({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.instructions = '',
  });

  final String itemId;
  final String name;
  final int price;
  final int quantity;
  final String instructions;

  int get lineTotal => price * quantity;

  factory OrderLine.fromMap(Map<String, dynamic> json) => OrderLine(
        itemId: json['itemId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
        instructions: json['instructions'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'instructions': instructions,
      };
}

/// A complete customer order placed from a table.
@immutable
class RestaurantOrder {
  const RestaurantOrder({
    required this.id,
    required this.tableNumber,
    required this.lines,
    required this.status,
    required this.placedAt,
  });

  final String id;
  final String tableNumber;
  final List<OrderLine> lines;
  final String status;
  final DateTime placedAt;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);
  int get subtotal => lines.fold(0, (sum, l) => sum + l.lineTotal);

  List<OrderLine> get linesWithInstructions =>
      lines.where((l) => l.instructions.isNotEmpty).toList();

  RestaurantOrder copyWith({
    String? status,
  }) =>
      RestaurantOrder(
        id: id,
        tableNumber: tableNumber,
        lines: lines,
        status: status ?? this.status,
        placedAt: placedAt,
      );
}
