import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Lifecycle of an order, from placement to completion.
///
/// The kitchen advances an order through these states and the customer tracker
/// renders the same values, so both products stay in lockstep.
enum OrderStatus {
  received('Received', 'Order placed'),
  accepted('Accepted', 'Kitchen acknowledged'),
  preparing('Preparing', 'Being cooked now'),
  ready('Ready', 'Pickup at counter'),
  delivered('Delivered', 'Served to table'),
  cancelled('Cancelled', 'Order was cancelled');

  const OrderStatus(this.label, this.description);

  final String label;
  final String description;

  Color get color => switch (this) {
        OrderStatus.received => AppColors.statusPending,
        OrderStatus.accepted => AppColors.statusPreparing,
        OrderStatus.preparing => AppColors.statusPreparing,
        OrderStatus.ready => AppColors.statusReady,
        OrderStatus.delivered => AppColors.statusServed,
        OrderStatus.cancelled => AppColors.statusCancelled,
      };

  IconData get icon => switch (this) {
        OrderStatus.received => Icons.receipt_long_rounded,
        OrderStatus.accepted => Icons.check_circle_outline_rounded,
        OrderStatus.preparing => Icons.local_fire_department_rounded,
        OrderStatus.ready => Icons.notifications_active_rounded,
        OrderStatus.delivered => Icons.done_all_rounded,
        OrderStatus.cancelled => Icons.cancel_rounded,
      };

  /// Statuses the kitchen actively works, in queue order.
  static List<OrderStatus> get activeQueue => const [
        OrderStatus.received,
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.ready,
      ];

  /// The next step in the happy path, or null at a terminal state.
  OrderStatus? get next => switch (this) {
        OrderStatus.received => OrderStatus.accepted,
        OrderStatus.accepted => OrderStatus.preparing,
        OrderStatus.preparing => OrderStatus.ready,
        OrderStatus.ready => OrderStatus.delivered,
        OrderStatus.delivered || OrderStatus.cancelled => null,
      };

  static OrderStatus fromName(String? value) => OrderStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => OrderStatus.received,
      );
}

/// Staff roles. Customers are anonymous and hold no role.
enum StaffRole {
  owner('Owner'),
  manager('Manager'),
  kitchenStaff('Kitchen Staff');

  const StaffRole(this.label);

  final String label;

  bool get canManageMenu => this == owner || this == manager;
  bool get canViewAnalytics => this == owner || this == manager;
  bool get canEditSettings => this == owner;

  static StaffRole fromName(String? value) => StaffRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => StaffRole.kitchenStaff,
      );
}

/// Whether a table is free, seated, or holding an open order.
enum TableStatus {
  available('Available'),
  occupied('Occupied'),
  reserved('Reserved');

  const TableStatus(this.label);

  final String label;

  Color get color => switch (this) {
        TableStatus.available => AppColors.success,
        TableStatus.occupied => AppColors.primary,
        TableStatus.reserved => AppColors.warning,
      };
}

/// How the diner is taking the order.
enum OrderType {
  dineIn('Dine In', Icons.restaurant_rounded),
  takeaway('Takeaway', Icons.shopping_bag_rounded);

  const OrderType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Dietary classification, shown as a badge on menu items.
enum FoodType {
  vegetarian('Veg', Color(0xFF2E7D32)),
  nonVegetarian('Non-Veg', Color(0xFFC62828)),
  vegan('Vegan', Color(0xFF00897B)),
  egg('Egg', Color(0xFFED6C02));

  const FoodType(this.label, this.color);

  final String label;
  final Color color;
}
